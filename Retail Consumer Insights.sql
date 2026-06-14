select * from sales_store
CREATE TABLE sales_store (
    transaction_id VARCHAR(15),
    customer_id VARCHAR(15),
    customer_name VARCHAR(30),
    customer_age INT,
    gender VARCHAR(15),
    product_id VARCHAR(15),
    product_name VARCHAR(15),
    product_category VARCHAR(15),
    quantity INT,
    prce FLOAT,
    payment_mode VARCHAR(15),
    purchase_date DATE,
    time_of_purchase TIME,
    status VARCHAR(15)
);
COPY sales_store 
FROM 'C:\public\Sales.csv' 
DELIMITER ',' 
CSV HEADER;

CREATE TABLE sales AS 
SELECT * FROM sales_store;

select * from sales;
select * from sales_store;

-- Data Cleaning
-- Step 1: To check for Duplicate

SELECT transaction_id, COUNT(*) AS duplicate_count
FROM sales
GROUP BY transaction_id
HAVING COUNT(transaction_id) > 1;

WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id 
               ORDER BY transaction_id
           ) AS row_num
    FROM sales
)
SELECT * FROM CTE 
WHERE row_num > 1;

DELETE FROM sales
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY transaction_id 
                   ORDER BY transaction_id
               ) AS row_num
        FROM sales
    ) t
    WHERE t.row_num > 1
);

SELECT transaction_id, COUNT(*) AS duplicate_count
FROM sales
GROUP BY transaction_id
HAVING COUNT(transaction_id) > 1;

-- Step 2 :- Correction of Headers

-- 1. Fix the price column name
ALTER TABLE sales
RENAME COLUMN "prce" TO "price";
select * from sales;

-- Step 3 :- To check Datatype

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sales';

-- Step 4 :- To Check Null Values
-- to check null count

SELECT 
    COUNT(*) - COUNT(transaction_id) AS transaction_id_nulls,
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(customer_name) AS customer_name_nulls,
    COUNT(*) - COUNT(customer_age) AS customer_age_nulls,
    COUNT(*) - COUNT(gender) AS gender_nulls,
    COUNT(*) - COUNT(product_id) AS product_id_nulls,
    COUNT(*) - COUNT(product_name) AS product_name_nulls,
    COUNT(*) - COUNT(product_category) AS product_category_nulls,
    COUNT(*) - COUNT(quantity) AS quantity_nulls,
    COUNT(*) - COUNT(price) AS price_nulls,
    COUNT(*) - COUNT(payment_mode) AS payment_mode_nulls,
    COUNT(*) - COUNT(purchase_date) AS purchase_date_nulls,
    COUNT(*) - COUNT(time_of_purchase) AS time_of_purchase_nulls,
    COUNT(*) - COUNT(status) AS status_nulls
FROM sales;

-- Treating null values 

SELECT * FROM sales
WHERE transaction_id IS NULL
   OR customer_id IS NULL
   OR customer_name IS NULL
   OR customer_age IS NULL
   OR gender IS NULL
   OR payment_mode IS NULL
   OR product_name IS NULL;

--  Deleting rows where critical primary identifiers are NULL

DELETE FROM sales 
WHERE transaction_id IS NULL;

-- Investigating and filling missing customer data

-- 1. Check other transactions for Ehsaan Ram to find his real customer_id
SELECT * FROM sales 
WHERE customer_name = 'Ehsaan Ram';

-- 2. Update the broken row with his correct customer_id
UPDATE sales
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900';

--  Filling missing customer data for Damini Raju

-- 1. Check other transactions for Damini Raju to verify her customer_id
SELECT * FROM sales 
WHERE customer_name = 'Damini Raju';

-- 2. Update her broken row with the correct customer_id (CUST1401)
UPDATE sales
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663';

-- Filling missing name, age, and gender for CUST1003

-- 1. Check other transactions for CUST1003 to see their details
SELECT * FROM sales 
WHERE customer_id = 'CUST1003';

-- 2. Update the broken row with the correct details
UPDATE sales
SET customer_name = 'Mahika Saini',
    customer_age = 35,
    gender = 'Male'
WHERE transaction_id = 'TXN432798';

-- Step 5:- Data Cleaning (Standardizing Gender)

-- 1. Check all unique variations currently in your gender column
SELECT DISTINCT gender 
FROM sales;

-- 2. Convert 'Male' to 'M'
UPDATE sales
SET gender = 'M'
WHERE gender = 'Male';

-- 3. Convert 'Female' to 'F'
UPDATE sales
SET gender = 'F'
WHERE gender = 'Female';

--  Standardizing Payment Mode

-- 1. Check all unique values to see the variations yourself
SELECT DISTINCT payment_mode 
FROM sales;

-- 2. Convert shorthand 'CC' entries to the full name 'Credit Card'
UPDATE sales
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC';

-- --Data Analysis--

-- 1. What are the top 5 most selling products by quantity? (Delivered only)
SELECT product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;
--Business Problem Solved: We don't know which product are most in demand.
--Business Impact: Helps prioritize stock and boost sales through targeted promotions.

-- 2. Which products are most frequently cancelled?
SELECT product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status = 'cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC
LIMIT 5;
--Business Problem Solved: Frequent cancellation affect revenue and customer trust.
--Business Impact: Identify poor performing products to improve quality or remove from catalog.

--What time of the day has the hoghest number of purchases?
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
    END AS time_of_day,
    COUNT(*) AS total_orders
FROM sales
GROUP BY time_of_day
ORDER BY total_orders DESC;
--Business Problem Solved: Find peak sales time.
--Business Impact: Optimizing staffing, promotions, and server loads.

--4.Who are the top 5 highest spending customers?
SELECT 
    customer_name, 
    '₹' || TO_CHAR(SUM(price * quantity), '999G999') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(price * quantity) DESC
LIMIT 5;
--Business Problem Solved: Identify VIP customers.
--Business Impact: Personalized offers, loyalty rewards , and retention.

--5.Which product category has the highest number of cancellation.
SELECT 
    product_category, 
    '₹ ' || TO_CHAR(SUM(price * quantity), '9,99,99,999') AS total_revenue
FROM 
    sales
GROUP BY 
    product_category
ORDER BY 
    SUM(price * quantity) DESC;
--Business Problem Solved: Identify top performing product categories.
--Business Impact: Refine product strategy, supply chain ,and promotions.
--allowing the business to invest more in high margin or high demand categories.

--6. What is the return/cancellation rate per product category?
-- 1. Cancellation Rate per Product Category
SELECT 
    product_category,
    TO_CHAR((COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*)), 'FM990.000') || '%' AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC;

-- 2. Return Rate per Product Category
SELECT 
    product_category,
    TO_CHAR((COUNT(CASE WHEN status = 'returned' THEN 1 END) * 100.0 / COUNT(*)), 'FM990.000') || '%' AS returned_percent
FROM sales
GROUP BY product_category
ORDER BY returned_percent DESC;
--Business Problrm Solved: Monitor dissatisfaction trends per category.
--Business Impact: Reduce returns , improve product descriptions / expectations.
--helps identify and fix product or logistic issues.

-- 7. What is the most preferred payment mode?
SELECT payment_mode, COUNT(payment_mode) AS total_count
FROM sales
GROUP BY payment_mode
ORDER BY total_count DESC;
--Business Problem Solved: Know which payment option customer prefer.
--Business Impact: Streamlimne payment processing, prioritize popular modes.

--8.How does age group affect purchasing behaviour?
SELECT 
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+' 
    END AS customer_age_group,
    -- Format with comma separators and prepend the Rupee symbol
    '₹' || to_char(SUM(price * quantity), 'FM99,99,99,999') AS total_purchase
FROM sales
GROUP BY 1 
ORDER BY SUM(price * quantity) DESC;
--Business Solved Problem: Understand customer demographics.
--Business Impact: Targeted marketing and product recommendations by age group.

--9. What is the monthly sales trend?
--Method 1.
SELECT 
    TO_CHAR(purchase_date, 'YYYY-MM') AS month_year,
    '₹' || TO_CHAR(SUM(price * quantity), 'FM99,99,99,999') AS total_sales,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY TO_CHAR(purchase_date, 'YYYY-MM')
ORDER BY month_year;

--Method 2.
SELECT 
    EXTRACT(YEAR FROM purchase_date) AS years,
    EXTRACT(MONTH FROM purchase_date) AS months,
    '₹' || TO_CHAR(SUM(price * quantity), 'FM99,99,99,999') AS total_sales,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY EXTRACT(YEAR FROM purchase_date), EXTRACT(MONTH FROM purchase_date)
ORDER BY years, months;
--Method 3. 
SELECT 
    EXTRACT(MONTH FROM purchase_date) AS months,
    '₹' || TO_CHAR(SUM(price * quantity), 'FM99,99,99,999') AS total_sales,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY EXTRACT(MONTH FROM purchase_date)
ORDER BY months;
--Business Problem Solved: Sales fluctuations go unnoticed.
--Business Impact: Plan inventory and marketing according to seasonal trends.

--10. Are certain genders buying more specific product categories?
--Method 1.
SELECT 
    gender, 
    product_category, 
    COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender, product_category
ORDER BY gender;

--Method 2.
SELECT 
    product_category,
    SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS "Male",
    SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS "Female"
FROM sales
GROUP BY product_category
ORDER BY product_category;
--Business Problem Solved: Gender based product preferences.
--Business Impact: Personalized ads, gender focused campaigns.