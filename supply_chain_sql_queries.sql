CREATE TABLE stg_supply_chain1 (
    type VARCHAR(50),
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order NUMERIC(10,2),
    sales_per_customer NUMERIC(10,2),
    delivery_status VARCHAR(100),
    late_delivery_risk INT,
    category_id INT,
    category_name VARCHAR(100),
    order_city VARCHAR(100),
    order_country VARCHAR(100),
    order_customer_id INT,
    order_date TIMESTAMP,
    order_id INT,
    order_item_cardprod_id INT,
    order_item_discount NUMERIC(10,2),
    order_item_discount_rate NUMERIC(10,2),
    order_item_id INT,
    order_item_product_price NUMERIC(10,2),
    order_item_profit_ratio NUMERIC(10,2),
    order_item_quantity INT,
    sales NUMERIC(10,2),
    order_item_total NUMERIC(10,2),
    order_profit_per_order NUMERIC(10,2),
    order_region VARCHAR(100),
    order_state VARCHAR(100),
    order_status VARCHAR(50),
    product_card_id INT,
    product_category_id INT,
    product_name VARCHAR(200),
    product_price NUMERIC(10,2),
    shipping_date TIMESTAMP,
    shipping_mode VARCHAR(50)
);

-- Data Cleaning & Sanity Validation Queries
-- remove duplicate

SELECT 
    order_id, 
    order_item_id, 
    COUNT(*) AS duplicate_count
FROM stg_supply_chain1
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Missing Values

select 
	count(*) as total_rows,
	count(order_id) as valid_orders,
	count(order_customer_id) as valid_customer,
	count(shipping_date) as valid_shipping_date
from stg_supply_chain1
where order_id is null or order_customer_id is null;
	
--Star Schema DDL Operations
-- 3 dimention 1 fact table

-- 1. Customer Dimension
CREATE TABLE dim_customers AS
SELECT DISTINCT 
    order_customer_id AS customer_id,
    sales_per_customer
FROM stg_supply_chain1;

-- 2. Product Dimension
CREATE TABLE dim_products AS
SELECT DISTINCT 
    product_card_id AS product_id,
    product_name,
    category_id,
    category_name,
    product_price
FROM stg_supply_chain1;

-- 3. Location/Geography Dimension
CREATE TABLE dim_location AS
SELECT DISTINCT 
    MD5(CONCAT(order_city, '_', order_state, '_', order_country, '_', order_region)) AS location_id,
    order_city AS city,
    order_state AS state,
    order_country AS country,
    order_region AS region
FROM stg_supply_chain1;

-- 4. Order Fact Table
CREATE TABLE fact_orders AS
SELECT 
    order_item_id,
    order_id,
    order_customer_id AS customer_id,
    product_card_id AS product_id,
    MD5(CONCAT(order_city, '_', order_state, '_', order_country, '_', order_region)) AS location_id,
    order_date,
    shipping_date,
    type AS payment_type,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    order_item_quantity AS quantity,
    order_item_product_price AS unit_price,
    sales AS total_sales,
    order_item_discount AS discount_amount,
    order_profit_per_order AS profit
FROM stg_supply_chain1;

--Core Supply Chain & Order Analytics Queries
--Shipping Lead-Time Variance & Delay Rate Analysis

SELECT 
    shipping_mode,
    COUNT(order_id) AS total_orders,
    AVG(days_for_shipping_real) AS avg_actual_days,
    AVG(days_for_shipment_scheduled) AS avg_scheduled_days,
    AVG(days_for_shipping_real - days_for_shipment_scheduled) AS avg_lead_time_variance,
    ROUND(SUM(late_delivery_risk)::numeric / COUNT(order_id) * 100, 2) AS delay_rate_percentage
FROM stg_supply_chain1
GROUP BY shipping_mode
ORDER BY delay_rate_percentage DESC;

--On-Time In-Full (OTIF) Delivery Metric

SELECT 
    order_region,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN delivery_status = 'Advance shipping' THEN 1 ELSE 0 END) AS advance_deliveries,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS late_deliveries,
    ROUND(
        (SUM(CASE WHEN delivery_status = 'Shipping on time' THEN 1 ELSE 0 END)::numeric / COUNT(order_id)) * 100, 2
    ) AS otif_on_time_rate_pct
FROM stg_supply_chain1
GROUP BY order_region
ORDER BY otif_on_time_rate_pct ASC;

--Financial & Profitability Analytics Queries

SELECT 
    order_region,
    order_country,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS total_revenue,
    SUM(order_profit_per_order) AS total_profit,
    ROUND((SUM(order_profit_per_order) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM stg_supply_chain1
GROUP BY order_region, order_country
HAVING SUM(sales) > 10000
ORDER BY total_profit ASC;

--Discount Impact on Profitability

select
	case
		when order_item_discount = 0 then 'No discount'
		when order_item_discount <= 0.10 then '0-10% Discount'
		when order_item_discount <= 0.20 then '10-20% discount'
		else 'Above 20% Discount'
	end as discount_bracket,
	count(order_id) as total_orders,
	avg(order_item_profit_ratio) as avg_profit_ratio,
	sum(order_profit_per_order) as total_profit
from stg_supply_chain1
group by 1
order by avg_profit_ratio asc;

--Advanced Supply Chain SQL (Window Functions & Moving Averages)
--30-Day Rolling Demand & Sales Trend

WITH daily_sales AS (
    SELECT 
        DATE_TRUNC('day', order_date) AS order_day,
        SUM(sales) AS daily_revenue,
        SUM(order_item_quantity) AS daily_quantity
    FROM stg_supply_chain1
    GROUP BY DATE_TRUNC('day', order_date)
)
SELECT 
    order_day,
    daily_revenue,
    AVG(daily_revenue) OVER (
        ORDER BY order_day 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30_day_avg_sales
FROM daily_sales
ORDER BY order_day;

--Customer Order Recency & Ranking 

SELECT 
    order_customer_id,
    COUNT(DISTINCT order_id) AS total_orders_placed,
    SUM(sales) AS total_lifetime_value,
    MAX(order_date) AS last_order_date,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS customer_sales_rank
FROM stg_supply_chain1
GROUP BY order_customer_id
ORDER BY customer_sales_rank ASC
LIMIT 10;