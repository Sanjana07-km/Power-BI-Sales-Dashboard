 use sales_dw;
/* total revenue by total sales*/
SELECT 
  SUM(revenue) AS total_revenue,
  SUM(net_revenue) AS total_net_revenue,
  SUM(quantity) AS total_units_sold,
  COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales;

/*Monthy sales trends*/
SELECT 
  d.year,
  d.month,
  SUM(f.net_revenue) AS net_revenue
FROM fact_sales f
JOIN dim_date d ON f.order_date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

/*Revenue by Region*/
SELECT
  r.region_name,
  SUM(f.net_revenue) AS net_revenue,
  SUM(f.quantity) AS units_sold
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY net_revenue DESC;

/*Top 10 products by revenue*/
SELECT
  p.product_id,
  p.name AS product_name,
  p.category,
  SUM(f.net_revenue) AS net_revenue,
  SUM(f.quantity) AS units_sold
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY net_revenue DESC
LIMIT 10;

/*Channel performance (online vs retail etc.*/
SELECT
  c.channel_name,
  COUNT(DISTINCT f.order_id) AS orders,
  SUM(f.net_revenue) AS net_revenue,
  AVG(f.net_revenue / f.quantity) AS avg_price_per_unit
FROM fact_sales f
JOIN dim_channel c ON f.channel_id = c.channel_id
GROUP BY c.channel_name
ORDER BY net_revenue DESC;

/*Monthly growth rate (MoM %)8*/
WITH monthly AS (
  SELECT
    d.year,
    d.month,
    SUM(f.net_revenue) AS net_revenue
  FROM fact_sales f
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY d.year, d.month
)
SELECT
  year, month, net_revenue,
  LAG(net_revenue) OVER (ORDER BY year, month) AS prev_net_revenue,
  ROUND((net_revenue - LAG(net_revenue) OVER (ORDER BY year, month)) / 
        NULLIF(LAG(net_revenue) OVER (ORDER BY year, month),0) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY year, month;

/*Average Order Value (AOV) and distribution*/
SELECT
  order_id,
  SUM(net_revenue) AS order_value
FROM fact_sales
GROUP BY order_id;

SELECT 
  AVG(order_value) AS average_order_value,
  (
    SELECT AVG(order_value)
    FROM (
      SELECT order_value,
             ROW_NUMBER() OVER (ORDER BY order_value) AS row_num,
             COUNT(*) OVER () AS total_rows
      FROM (
        SELECT order_id, SUM(net_revenue) AS order_value
        FROM fact_sales
        GROUP BY order_id
      ) sub
    ) ranked
    WHERE row_num IN (FLOOR((total_rows + 1)/2), CEIL((total_rows + 1)/2))
  ) AS median_order_value
FROM (
  SELECT order_id, SUM(net_revenue) AS order_value
  FROM fact_sales
  GROUP BY order_id
) t;

/*Repeat vs new customers (cohort-ish check)*/
-- total unique customers and how many placed >1 order
SELECT
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(CASE WHEN orders_per_customer > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM (
  SELECT customer_id, COUNT(DISTINCT order_id) AS orders_per_customer
  FROM fact_sales
  GROUP BY customer_id
) t;

/*Discount impact on sales (compare with/without discount)*/
SELECT
  CASE WHEN f.discount > 0 THEN 'discounted' ELSE 'no_discount' END as discount_flag,
  COUNT(DISTINCT f.order_id) AS orders,
  SUM(f.net_revenue) AS net_revenue,
  AVG(f.net_revenue) AS avg_order_value
FROM fact_sales f
GROUP BY discount_flag;

/*Sales by weekday vs weekend*/
SELECT
  d.is_weekend,
  SUM(f.net_revenue) AS net_revenue,
  COUNT(DISTINCT f.order_id) AS orders
FROM fact_sales f
JOIN dim_date d ON f.order_date_id = d.date_id
GROUP BY d.is_weekend;

/*Top customers by revenue (concentration)*/
SELECT
  c.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  SUM(f.net_revenue) AS total_spent,
  COUNT(DISTINCT f.order_id) AS orders
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 10;

/*Running total (cumulative sales)*/
SELECT
  d.year,
  d.month,
  SUM(f.net_revenue) AS monthly_net_revenue,
  SUM(SUM(f.net_revenue)) OVER (ORDER BY d.year, d.month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_net_revenue
FROM fact_sales f
JOIN dim_date d ON f.order_date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

/*advanced queries*/
WITH customer_rfm AS (
  SELECT
    c.customer_id,
    MAX(d.full_date) AS last_purchase_date,
    COUNT(DISTINCT f.order_id) AS frequency,
    SUM(f.net_revenue) AS monetary
  FROM fact_sales f
  JOIN dim_customer c ON f.customer_id = c.customer_id
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY c.customer_id
)
SELECT
  customer_id,
  DATEDIFF(CURDATE(), last_purchase_date) AS recency_days,
  frequency,
  monetary
FROM customer_rfm
ORDER BY monetary DESC;

/*Gross Margin by Product*/
SELECT
  p.name AS product_name,
  p.category,
  SUM(f.net_revenue) AS total_revenue,
  ROUND(SUM(f.net_revenue) * 0.3, 2) AS estimated_gross_profit,
  30 AS assumed_profit_margin_pct
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.name, p.category
ORDER BY total_revenue DESC;

/*Year-over-Year (YoY) Growth*/
WITH yearly_sales AS (
  SELECT
    d.year,
    SUM(f.net_revenue) AS total_revenue
  FROM fact_sales f
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY d.year
)
SELECT
  year,
  total_revenue,
  LAG(total_revenue) OVER (ORDER BY year) AS prev_year_revenue,
  ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY year)) / 
        LAG(total_revenue) OVER (ORDER BY year) * 100, 2) AS yoy_growth_pct
FROM yearly_sales;

/*MOnthly Average REvenue  */
WITH monthly_sales AS (
  SELECT
    d.year,
    d.month,
    SUM(f.net_revenue) AS revenue
  FROM fact_sales f
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY d.year, d.month
)
SELECT
  year,
  month,
  revenue,
  ROUND(AVG(revenue) OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly_sales
ORDER BY year, month;


/*Region x Channel Matrix*/
SELECT
  r.region_name,
  c.channel_name,
  SUM(f.net_revenue) AS total_revenue,
  SUM(f.quantity) AS total_units
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
JOIN dim_channel c ON f.channel_id = c.channel_id
GROUP BY r.region_name, c.channel_name
ORDER BY total_revenue DESC;

/*Customer Lifetime Value (CLV)*/
WITH customer_spend AS (
  SELECT
    f.customer_id,
    SUM(f.net_revenue) AS total_spent,
    COUNT(DISTINCT f.order_id) AS total_orders,
    MIN(d.full_date) AS first_purchase,
    MAX(d.full_date) AS last_purchase
  FROM fact_sales f
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY f.customer_id
)
SELECT
  customer_id,
  total_spent,
  total_orders,
  ROUND(total_spent / total_orders, 2) AS avg_order_value,
  DATEDIFF(last_purchase, first_purchase) AS active_days
FROM customer_spend
ORDER BY total_spent DESC;

/*Anomaly Detection / Outlier Sales*/
WITH daily_sales AS (
  SELECT
    d.full_date,
    SUM(f.net_revenue) AS revenue
  FROM fact_sales f
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY d.full_date
)
SELECT
  full_date,
  revenue,
  ROUND(AVG(revenue) OVER (), 2) AS avg_revenue,
  ROUND(STDDEV(revenue) OVER (), 2) AS std_dev,
  CASE 
    WHEN revenue > AVG(revenue) OVER () + 2 * STDDEV(revenue) OVER () THEN 'High Outlier'
    WHEN revenue < AVG(revenue) OVER () - 2 * STDDEV(revenue) OVER () THEN 'Low Outlier'
    ELSE 'Normal'
  END AS anomaly_flag
FROM daily_sales
ORDER BY full_date;

/*Channel Conversion Efficiency*/
SELECT
  c.channel_name,
  COUNT(DISTINCT f.order_id) AS total_orders,
  COUNT(DISTINCT f.customer_id) AS total_customers,
  SUM(f.net_revenue) AS total_revenue,
  ROUND(SUM(f.net_revenue)/COUNT(DISTINCT f.order_id), 2) AS avg_revenue_per_order,
  ROUND(SUM(f.net_revenue)/COUNT(DISTINCT f.customer_id), 2) AS avg_revenue_per_customer
FROM fact_sales f
JOIN dim_channel c ON f.channel_id = c.channel_id
GROUP BY c.channel_name
ORDER BY total_revenue DESC;


/*Category-Region Performance Matrix*/
SELECT
  r.region_name,
  p.category,
  SUM(f.net_revenue) AS total_revenue,
  SUM(f.quantity) AS total_units
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name, p.category
ORDER BY total_revenue DESC;


/*Seasonality and Month-over-Month Patterns*/
SELECT
  d.year,
  d.month,
  DATE_FORMAT(d.full_date, '%b %Y') AS month_label,
  SUM(f.net_revenue) AS monthly_revenue,
  AVG(f.net_revenue) AS avg_order_value,
  COUNT(DISTINCT f.order_id) AS orders
FROM fact_sales f
JOIN dim_date d ON f.order_date_id = d.date_id
GROUP BY d.year, d.month, month_label
ORDER BY d.year, d.month;

/*Customer Value Tiering (Gold/Silver/Bronze)*/

WITH customer_spend AS (
  SELECT
    f.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(f.net_revenue) AS total_spent
  FROM fact_sales f
  JOIN dim_customer c ON f.customer_id = c.customer_id
  GROUP BY f.customer_id, customer_name
),
ranked AS (
  SELECT
    customer_id,
    customer_name,
    total_spent,
    NTILE(10) OVER (ORDER BY total_spent DESC) AS decile
  FROM customer_spend
)
SELECT
  customer_name,
  total_spent,
  CASE 
    WHEN decile <= 1 THEN 'Gold (Top 10%)'
    WHEN decile <= 5 THEN 'Silver (Mid 40%)'
    ELSE 'Bronze (Bottom 50%)'
  END AS customer_tier
FROM ranked
ORDER BY total_spent DESC;

/*profit by region*/
SELECT
  r.region_name,
  SUM(f.net_revenue) AS total_revenue,
  ROUND(SUM(f.net_revenue)*0.3, 2) AS estimated_gross_profit
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY estimated_gross_profit DESC;

/*profit by product*/
SELECT
  r.region_name,
  SUM(f.net_revenue) AS total_revenue,
  ROUND(SUM(f.net_revenue)*0.3, 2) AS estimated_gross_profit
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY estimated_gross_profit DESC;

/*profit by channel*/
SELECT
  c.channel_name,
  SUM(f.net_revenue) AS total_revenue,
  ROUND(SUM(f.net_revenue)*0.3, 2) AS estimated_gross_profit
FROM fact_sales f
JOIN dim_channel c ON f.channel_id = c.channel_id
GROUP BY c.channel_name
ORDER BY estimated_gross_profit DESC;



/*Discount vs Units Sold Correlation*/
SELECT
  CASE 
    WHEN f.discount = 0 THEN 'No Discount'
    WHEN f.discount BETWEEN 0.01 AND 0.10 THEN '0-10% Discount'
    WHEN f.discount BETWEEN 0.11 AND 0.25 THEN '11-25% Discount'
    ELSE '>25% Discount'
  END AS discount_range,
  COUNT(DISTINCT f.order_id) AS orders,
  SUM(f.quantity) AS total_units_sold,
  AVG(f.quantity) AS avg_units_per_order
FROM fact_sales f
GROUP BY discount_range
ORDER BY total_units_sold DESC;

/*Sales Forecasting (Simple Trend Projection using Moving Average)*/
WITH monthly_sales AS (
  SELECT
    d.year,
    d.month,
    SUM(f.net_revenue) AS monthly_revenue
  FROM fact_sales f
  JOIN dim_date d ON f.order_date_id = d.date_id
  GROUP BY d.year, d.month
)
SELECT
  year,
  month,
  monthly_revenue,
  ROUND(AVG(monthly_revenue) OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS forecast_next_month
FROM monthly_sales
ORDER BY year, month;





















DESC fact_sales;


















