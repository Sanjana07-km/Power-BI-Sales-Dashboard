SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_region;
DROP TABLE IF EXISTS dim_channel;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_date;
SET FOREIGN_KEY_CHECKS = 1;
SHOW DATABASES;
CREATE DATABASE sales_dw;
use sales_dw;
SELECT DATABASE();

CREATE TABLE dim_date (
  date_id INT NOT NULL PRIMARY KEY,         -- e.g., 20250101
  full_date DATE NOT NULL,
  day INT,
  month INT,
  year INT,
  weekday VARCHAR(20),
  is_weekend TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_customer (
  customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(150),
  phone VARCHAR(50),
  signup_date DATE,
  city VARCHAR(100),
  country VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_product (
  product_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50),
  name VARCHAR(150),
  category VARCHAR(100),
  brand VARCHAR(100),
  price DECIMAL(10,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_channel (
  channel_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  channel_name VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dim_region (
  region_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  region_name VARCHAR(100),
  country VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fact_sales (
  sale_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  order_date_id INT NOT NULL,
  customer_id INT NOT NULL,
  product_id INT NOT NULL,
  channel_id INT,
  region_id INT,
  quantity INT DEFAULT 1,
  revenue DECIMAL(12,2) DEFAULT 0.00,
  discount DECIMAL(12,2) DEFAULT 0.00,
  net_revenue DECIMAL(12,2) AS (revenue - discount) STORED,
  unit_price DECIMAL(10,2) DEFAULT 0.00,
  CONSTRAINT fk_fact_date FOREIGN KEY (order_date_id) REFERENCES dim_date(date_id),
  CONSTRAINT fk_fact_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  CONSTRAINT fk_fact_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  CONSTRAINT fk_fact_channel FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id),
  CONSTRAINT fk_fact_region FOREIGN KEY (region_id) REFERENCES dim_region(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO fact_sales 
(order_id, order_date_id, customer_id, product_id, channel_id, region_id, quantity, revenue, discount, unit_price)
VALUES 
(1001, 20250101, 1, 1, 1, 1, 2, 1399.98, 50.00, 699.99),
(1002, 20250102, 2, 3, 2, 2, 1, 249.50, 0.00, 249.50),
(1003, 20250110, 3, 2, 3, 3, 3, 449.97, 20.00, 149.99),
(1004, 20250115, 4, 4, 1, 4, 1, 199.00, 10.00, 199.00),
(1005, 20250125, 5, 5, 2, 5, 1, 120.00, 0.00, 120.00),
(1006, 20250201, 6, 6, 3, 6, 2, 179.98, 20.00, 89.99),
(1007, 20250214, 7, 8, 1, 7, 1, 89.50, 5.00, 89.50),
(1008, 20250301, 8, 9, 2, 8, 4, 51.00, 0.00, 12.75),
(1009, 20250315, 9, 7, 3, 9, 2, 80.00, 0.00, 40.00),
(1010, 20250401, 10, 10, 1, 10, 3, 47.97, 5.00, 15.99);

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE dim_date;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO dim_date (date_id, full_date, day, month, year, weekday, is_weekend)
VALUES
(20250101, '2025-01-01', 1, 1, 2025, 'Wednesday', 0),
(20250102, '2025-01-02', 2, 1, 2025, 'Thursday', 0),
(20250110, '2025-01-10', 10, 1, 2025, 'Friday', 0),
(20250115, '2025-01-15', 15, 1, 2025, 'Wednesday', 0),
(20250125, '2025-01-25', 25, 1, 2025, 'Saturday', 1),
(20250201, '2025-02-01', 1, 2, 2025, 'Saturday', 1),
(20250214, '2025-02-14', 14, 2, 2025, 'Friday', 0),
(20250301, '2025-03-01', 1, 3, 2025, 'Saturday', 1),
(20250315, '2025-03-15', 15, 3, 2025, 'Saturday', 1),
(20250401, '2025-04-01', 1, 4, 2025, 'Tuesday', 0);







SET FOREIGN_KEY_CHECKS = 1;
SHOW DATABASES;
CREATE DATABASE sales_dw;



 



INSERT INTO dim_date (date_id, full_date, day, month, year, weekday, is_weekend) VALUES
(20250101, '2025-01-01', 1, 1, 2025, 'Wednesday', 0),
(20250102, '2025-01-02', 2, 1, 2025, 'Thursday', 0),
(20250110, '2025-01-10',10, 1, 2025, 'Friday', 0),
(20250115, '2025-01-15',15, 1, 2025, 'Wednesday', 0),
(20250125, '2025-01-25',25, 1, 2025, 'Saturday', 1),
(20250201, '2025-02-01',1, 2, 2025, 'Saturday', 1),
(20250214, '2025-02-14',14, 2, 2025, 'Friday', 0),
(20250301, '2025-03-01',1, 3, 2025, 'Saturday', 1),
(20250315, '2025-03-15',15, 3, 2025, 'Saturday', 1),
(20250401, '2025-04-01',1, 4, 2025, 'Tuesday', 0);

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE dim_date;
SET FOREIGN_KEY_CHECKS = 1;



 SELECT * FROM dim_channel;
 INSERT INTO dim_channel (channel_name)
VALUES ('Online'), ('Retail Store'), ('Mobile App');

 
 SELECT * FROM dim_customer;
 
 INSERT INTO dim_customer 
(first_name, last_name, email, phone, signup_date, city, country)
VALUES
('Aarav', 'Sharma', 'aarav.sharma@example.com', '+91-9876543210', '2024-01-05', 'Mumbai', 'India'),
('Emma', 'Johnson', 'emma.johnson@example.com', '+44-7551234567', '2023-11-15', 'London', 'UK'),
('Liam', 'Brown', 'liam.brown@example.com', '+1-2025550148', '2024-02-20', 'New York', 'USA'),
('Sofia', 'Garcia', 'sofia.garcia@example.com', '+34-612345678', '2023-12-30', 'Madrid', 'Spain'),
('Noah', 'Patel', 'noah.patel@example.com', '+91-9988776655', '2024-03-12', 'Delhi', 'India'),
('Olivia', 'Miller', 'olivia.miller@example.com', '+61-412345678', '2024-05-01', 'Sydney', 'Australia'),
('Ethan', 'Kim', 'ethan.kim@example.com', '+82-1045678901', '2024-04-14', 'Seoul', 'South Korea'),
('Mia', 'Singh', 'mia.singh@example.com', '+91-9090909090', '2024-06-10', 'Bangalore', 'India'),
('Lucas', 'Wong', 'lucas.wong@example.com', '+65-81234567', '2024-01-18', 'Singapore', 'Singapore'),
('Isabella', 'Martinez', 'isabella.martinez@example.com', '+52-5512345678', '2024-02-22', 'Mexico City', 'Mexico');

SELECT * FROM dim_product;

INSERT INTO dim_product 
(sku, name, category, brand, price)
VALUES
('ELEC001', 'Smartphone X200', 'Electronics', 'TechNova', 699.99),
('ELEC002', 'Wireless Earbuds Pro', 'Electronics', 'SoundMax', 149.99),
('HOME001', 'Vacuum Cleaner V12', 'Home Appliances', 'CleanSweep', 249.50),
('HOME002', 'Air Purifier A5', 'Home Appliances', 'PureAir', 199.00),
('FASH001', 'Men’s Leather Jacket', 'Fashion', 'UrbanWear', 120.00),
('FASH002', 'Women’s Handbag Classic', 'Fashion', 'Elegance', 89.99),
('SPORT001', 'Yoga Mat Deluxe', 'Sports', 'FlexiFit', 40.00),
('SPORT002', 'Running Shoes R7', 'Sports', 'RunPro', 89.50),
('GROC001', 'Organic Green Tea', 'Groceries', 'NatureLeaf', 12.75),
('GROC002', 'Protein Bar Pack', 'Groceries', 'FitFuel', 15.99);

INSERT INTO dim_region 
(region_name, country)
VALUES
('North', 'India'),
('South', 'India'),
('East', 'India'),
('West', 'India'),
('London Metro', 'UK'),
('New York Area', 'USA'),
('Sydney Region', 'Australia'),
('Madrid Central', 'Spain'),
('Seoul City', 'South Korea'),
('Singapore District', 'Singapore');

INSERT INTO fact_sales
  (order_id, order_date_id, customer_id, product_id, channel_id, region_id, quantity, revenue, discount, unit_price)
VALUES
  (1001, 20250101, 1, 1, 1, 1, 2, 1399.98, 50.00, 699.99),
  (1002, 20250102, 2, 3, 2, 2, 1, 249.50,   0.00, 249.50),
  (1003, 20250110, 3, 2, 3, 3, 3, 449.97,  20.00, 149.99),
  (1004, 20250115, 4, 4, 1, 4, 1, 199.00,  10.00, 199.00),
  (1005, 20250125, 5, 5, 2, 5, 1, 120.00,   0.00, 120.00),
  (1006, 20250201, 6, 6, 3, 6, 2, 179.98,  20.00,  89.99),
  (1007, 20250214, 7, 8, 1, 7, 1,  89.50,   5.00,  89.50),
  (1008, 20250301, 8, 9, 2, 8, 4,  51.00,   0.00,  12.75),
  (1009, 20250315, 9, 7, 3, 9, 2,  80.00,   0.00,  40.00),
  (1010, 20250401,10,10, 1,10, 3,  47.97,   5.00,  15.99);
  
  select * from fact_sales;



SELECT 
  SUM(revenue) AS total_revenue,
  SUM(net_revenue) AS total_net_revenue,
  SUM(quantity) AS total_units_sold,
  COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales;


show tables;
SHOW TABLES LIKE 'dim_date';
CREATE TABLE fact_sales (
  sale_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  order_date_id INT NOT NULL,
  customer_id INT NOT NULL,
  product_id INT NOT NULL,
  channel_id INT,
  region_id INT,
  quantity INT DEFAULT 1,
  revenue DECIMAL(12,2) DEFAULT 0.00,
  discount DECIMAL(12,2) DEFAULT 0.00,
  net_revenue DECIMAL(12,2) AS (revenue - discount) STORED,
  unit_price DECIMAL(10,2) DEFAULT 0.00,
  CONSTRAINT fk_fact_date FOREIGN KEY (order_date_id) REFERENCES dim_date(date_id),
  CONSTRAINT fk_fact_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  CONSTRAINT fk_fact_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  CONSTRAINT fk_fact_channel FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id),
  CONSTRAINT fk_fact_region FOREIGN KEY (region_id) REFERENCES dim_region(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SHOW TABLES LIKE 'dim_customer';

SHOW CREATE TABLE dim_customer;




