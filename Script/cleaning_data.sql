/*
Purpose :
This SQL script is designed to clean, transform, and reload the orders_cafe table using raw transactional data from the transaction_cafe table. 
The goal is to ensure that all inconsistencies, null values, and incorrect calculations are corrected prior to advanced analytics.
it includes checks for:

	* Clean Missing Value
	* Calculate Accurate Fields
	* Standardize Nulls
	* Invalid date ranges
	* Data consistency between related fields

==============================================================================================
------------------------------------DATA WRANGLING------------------------------------
==============================================================================================
*/

------------------------------------Cleaning Data-------------------------------------

TRUNCATE TABLE orders_cafe;
WITH tr_cafe AS (
	SELECT
	transaction_ID,
	CASE 
		WHEN (product_name IS NULL ) AND price = 2.00 THEN 'Coffee' 
		WHEN (product_name IS NULL ) AND price = 1.00 THEN 'Cookie' 
		WHEN (product_name IS NULL ) AND price = 5.00 THEN 'Salad' 
		WHEN (product_name IS NULL ) AND price = 1.50 THEN 'Tea'
		ELSE product_name 
	END AS product_name, 
	quantity,
	-- Caculate
    CASE 
        WHEN price IS NULL THEN 
            CASE product_name
				WHEN 'Coffee' THEN 2.00
				WHEN 'Cookie' THEN 1.00
				WHEN 'Salad' THEN 5.00
				WHEN 'Tea' THEN 1.50
				WHEN 'Sandwich' THEN 4.00
				WHEN 'Smoothie' THEN 4.00
				WHEN 'Cake' THEN 3.00
				WHEN 'Juice' THEN 3.00
                ELSE NULL
            END
        ELSE price
	END AS price,
	total_spent,
	COALESCE(payment_method, 'N/A') AS payment_method,
	COALESCE(order_type, 'N/A') AS order_type,
	COALESCE(transaction_date, '2000-01-01') AS transaction_date
FROM transaction_cafe
),

tr_cafe_calculation AS(
	SELECT
	transaction_id,
	COALESCE(product_name, 'N/A') product_name,
	CASE 
		WHEN quantity IS NULL OR quantity <= 0 
		THEN CAST(total_spent / NULLIF(price, 0) AS INT)
		ELSE quantity -- Derive price if original value is invalid
	END AS quantity,
	CASE 
		WHEN price IS NULL OR price <= 0 
		THEN CAST(total_spent / NULLIF(quantity, 0) AS DECIMAL(10,2))
		ELSE price  -- Derive price if original value is invalid
	END AS price,
	CASE 
		WHEN total_spent IS NULL OR total_spent <= 0 OR total_spent != quantity * ABS(price) 
		THEN quantity * ABS(price)
		ELSE total_spent
	END AS total_spent,
	payment_method,
	order_type,
	transaction_date
FROM tr_cafe
),
tr_cafe_final AS(
	SELECT
	transaction_id,
	CASE 
		WHEN product_name = 'N/A' AND price = 2.00 THEN 'Coffee' 
		WHEN product_name = 'N/A' AND price = 1.00 THEN 'Cookie' 
		WHEN product_name = 'N/A' AND price = 5.00 THEN 'Salad' 
		WHEN product_name = 'N/A' AND price = 1.50 THEN 'Tea'
		ELSE product_name 
	END AS product_name,
	quantity,
	price,
	total_spent,
	payment_method,
	order_type,
	transaction_date
FROM tr_cafe_calculation
)
INSERT INTO orders_cafe
(
	transaction_id,
	Product_name,
	quantity,
	price,
	total_spent,
	payment_method,
	order_type,
	transaction_date
)
SELECT 	
	transaction_id,
	Product_name,
	quantity,
	price,
	total_spent,
	payment_method,
	order_type,
	transaction_date
FROM tr_cafe_final
where price IS NOT NULL
AND quantity IS NOT  NULL
AND total_spent IS NOT  NULL
AND product_name != 'N/A'
AND payment_method != 'N/A'
AND order_type != 'N/A'
AND transaction_date != '2000-01-01'







