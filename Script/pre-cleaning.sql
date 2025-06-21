/*
Purpose : A critical step preceding data cleaning is conducting a data quality check to ensure 
the dataset meets essential standards of consistency,accuracy,and standardization.

==============================================================================================
------------------------------------DATA WRANGLING------------------------------------
==============================================================================================
*/

------------------------------------QUALITY CHECKS------------------------------------
-- Check for Nulls or duplicates
-- Expectation : No result

SELECT 
	transaction_id,
	COUNT(*)
FROM transaction_cafe
GROUP BY transaction_id
HAVING COUNT(*) > 1 OR transaction_id IS NULL

-- Check for Nulls or negatives values
-- Expectation : No result

SELECT 
	quantity
FROM transaction_cafe
HAVING quantity < 0 OR quantity IS NULL;


-- Check for Nulls or negatives values
-- Expectation : No result

SELECT 
	price
FROM transaction_cafe
HAVING price < 0 OR price IS NULL;

-- CHECK for unwanted spaces
-- CHECK payment method IS NULL
-- Expectation : No result


SELECT
	payment_method
FROM transaction_cafe
WHERE payment_Method != TRIM(Payment_Method)
OR payment_method IS NULL;


-- Check for unwanted spaces
-- Check order type IS NULL
-- Expectation : No result
SELECT
	order_type
FROM transaction_cafe
WHERE order_type != TRIM(order_type)
OR order_type IS NULL;

-- Check for unwanted spaces
-- Check product name IS NULL
-- Expectation : No result
SELECT
	product_name
FROM transaction_cafe
WHERE product_name != TRIM(product_name)
OR product_name IS NULL;


-- Check transaction date IS NULL
-- Check for Invalid dates
-- Expectation : No result
SELECT
	transaction_date,
FROM transaction_cafe
WHERE transaction_date IS NULL


-- Data Standardization & Consistency
SELECT DISTINCT
	payment_method
FROM transaction_cafe;

-- Data Standardization & Consistency
SELECT DISTINCT
	order_type
FROM transaction_cafe;

------------------------------------AFTER CLEANING------------------------------------

SELECT flag_last
FROM (
SELECT
ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY product_name DESC) flag_last
FROM orders_cafe ) t
WHERE flag_last > 1

SELECT * FROM orders_cafe
WHERE 
price IS NULL
OR quantity IS NULL
or total_spent IS NULL
OR transaction_date IS NULL
OR product_name IS NULL
OR order_type IS NULL
