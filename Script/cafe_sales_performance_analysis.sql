/*
Purpose: 
This report presents a structured analysis of transactional sales data using SQL queries. 
The objective is to gain a deep understanding of business performance through various analytical angles. The analysis includes:

	* Aggregating key sales metrics (total, average, highest, lowest).
	* Examining sales distribution across products, payment methods, and order types.
	* Identifying top-performing products based on revenue and quantity.
	* Analyzing temporal trends such as daily, weekday/weekend patterns, and month-over-month changes.
	* Comparing performance against benchmarks (e.g., specific product sales).
	* Categorizing transactions and performance into levels such as low, medium, and high.
	* Evaluating cumulative sales trends and applying moving average techniques


SQL Functions Used: COUNT(), SUM(), AVG(), MAX(), MIN(), RANK(), ROW_NUMBER(), LAG(), LEAD(), CASE, WINDOW FUNCTIONS



==============================================================================================
----------------------------Explaoratory Data Analysis (EDA)----------------------------------
==============================================================================================

*/
---------------------------------BASIC METRICS---------------------------------
-- How much is total sales
SELECT SUM(total_spent) total_sales
FROM orders_cafe;

-- How many total transactions were recorded
SELECT COUNT (*) total_transactions
FROM orders_cafe;

-- What is the average sales amount per transaction
SELECT AVG(total_spent) avg_sales
FROM orders_cafe;

-- What is the highest sales amount in a single transaction
SELECT MAX(total_spent) AS highest_sales
FROM orders_cafe;

-- What is the Lowest Sales across all orders and by Product
SELECT
	transaction_id,
	product_name,
	MIN(total_spent) OVER () lowest_sales_overall,
    MIN(total_spent) OVER (PARTITION BY product_name) lowest_sales_by_product
FROM orders_cafe;

-- What are the highest and lowest sales, and how much does it deviate from the minimum and maximum
SELECT
	product_name,
	total_spent,
    MAX(total_spent) OVER () AS highest_sales,
    MIN(total_spent) OVER () AS lowest_sales,
    total_spent - MIN(total_spent) OVER () AS deviation_from_min,
    MAX(total_spent) OVER () - total_spent AS deviation_from_max
FROM orders_cafe;

---------------------------------SALES OVERVIEW---------------------------------

-- What is the percentage of total sales contributed by each product
SELECT 
	product_name, 
    CAST(ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM orders_cafe), 2) AS decimal(10, 2)) sales_percentage
FROM orders_cafe
GROUP BY product_name
ORDER BY sales_percentage DESC;

-- What is the total sales and percentage by payment method
SELECT
	payment_method,
	SUM(total_spent) total_sales,
	CAST(ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM orders_cafe), 2) AS decimal (10,2)) percentage_payment
FROM orders_cafe
GROUP BY payment_method;

--What is the total sales and percentage by product
SELECT
	product_name,
	SUM(total_spent) total_sales,
	CAST(ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM orders_cafe), 2) AS decimal (10,2)) percentage_product
FROM orders_cafe
GROUP BY product_name

-- What are the top 5 products with the highest total sales?
SELECT TOP 5
	product_name,
	SUM(total_spent) total_sales,
	CAST(ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM orders_cafe), 2) AS decimal (10,2)) percentage_product
FROM orders_cafe
GROUP BY product_name;


-- What is the total sales and percentage by order type
SELECT
	order_type,
	SUM(total_spent) total_sales,
	CAST(ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM orders_cafe), 2) AS decimal (10,2)) percentage_product
FROM orders_cafe 
GROUP BY order_type;

-- What are the top 5 products by quantity sold
SELECT TOP 5
product_name,
SUM(quantity) total_quantity
FROM orders_cafe
GROUP BY product_name
ORDER BY total_quantity DESC;


--What are the lowest and highest sales values for each transaction date, and how much does each order's sale differ from the lowest sale for that date
SELECT
    transaction_id,
	transaction_date,
    Product_name,
    total_spent,
    FIRST_VALUE(total_spent) OVER (PARTITION BY transaction_date ORDER BY total_spent) lowest_sales,
    LAST_VALUE(total_spent) OVER (PARTITION BY transaction_date ORDER BY total_spent ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) highest_sales,
    total_spent - FIRST_VALUE(total_spent) OVER ( PARTITION BY transaction_date  ORDER BY total_spent ) sales_difference
FROM orders_cafe
ORDER BY transaction_date;

-- How can each transaction in the cafe_sales table be categorized into Low, Medium, or High sales based on the Total Spent value
WITH product_sales_bucket AS (
SELECT
product_name,
total_spent,
CASE 
	WHEN total_spent <= 5 THEN 'low'
	WHEN total_spent <= 10 THEN 'medium'
ELSE 'high'
END AS sales_bucket
FROM orders_cafe
)

SELECT sales_bucket,
COUNT(product_name) total_product
FROM product_sales_bucket
GROUP BY sales_bucket;

---------------------------------COMPARATIVE SALES ---------------------------------

-- Which products are more expensive than cake?
SELECT *
FROM orders_cafe
WHERE price > ALL (
    SELECT price
    FROM orders_cafe
    WHERE product_name = 'cake'
);

-- Which transactions have total spending higher than coffee?
SELECT *
FROM orders_cafe
WHERE total_spent > ALL (
    SELECT total_spent
    FROM orders_cafe
    WHERE product_name= 'coffee'
);

-- What is the most common payment method used by customers?
SELECT
	payment_method, 
	COUNT(payment_method) common_payment_method 
FROM orders_cafe 
GROUP BY payment_method
ORDER BY common_payment_method DESC;

-- Which order type is more frequently used by customers
SELECT
	order_type, 
	COUNT(order_type) common_order_type
FROM orders_cafe 
GROUP BY order_type
ORDER BY common_order_type DESC;

-- Which products have more transactions than the average of all products?
SELECT 
  product_name,
  COUNT(*) AS total_transaction
FROM orders_cafe
GROUP BY product_name
HAVING COUNT(*) > (
  SELECT AVG(product_transaction) 
  FROM (
    SELECT COUNT(*) AS product_transaction
    FROM orders_cafe
    GROUP BY product_name
  ) AS avg_data
);


---------------------------------TIME BASED ANALYSIS---------------------------------

-- What is the total sales on each workday ?
SELECT
	transaction_date,
	SUM(total_spent) total_sales,
	FORMAT(transaction_date, 'dddd') day_name
FROM orders_cafe
WHERE FORMAT(transaction_date, 'dddd') NOT IN ('Sunday', 'Saturday')
GROUP BY 
transaction_date, 
FORMAT(transaction_date, 'dddd');

-- What are the most sold products during weekends?
SELECT 
  FORMAT(transaction_date, 'dddd') AS day_name,
  product_name,
  COUNT(*) AS total_transactions
FROM orders_cafe
WHERE FORMAT(transaction_date, 'dddd') IN ('Saturday', 'Sunday')
GROUP BY 
  FORMAT(transaction_date, 'dddd'),
  product_name
ORDER BY total_transactions DESC;

-- How are product sales distributed between weekdays and weekends?
WITH sales_product AS(
SELECT
	SUM(total_spent) total_sales,
	product_name,
	FORMAT(transaction_date, 'dddd') day_name
FROM orders_cafe
GROUP BY product_name,
FORMAT(transaction_date, 'dddd')
)

SELECT
product_name,
CASE 
	WHEN day_name IN ('Saturday', 'Sunday') THEN 'Weekend'
	ELSE 'Weekday'
END AS category_day,
total_sales
FROM sales_product;


-- How does each day's sales compare to the previous and next days
SELECT 
    transaction_date,
    total_sales,
    LAG(total_sales) OVER (ORDER BY transaction_date) Prev_Day_Sales,
    LEAD(total_sales) OVER (ORDER BY transaction_date) Next_Day_Sales,
	total_sales - LEAD(total_sales) OVER (ORDER BY transaction_date) diff_from_prev
FROM (
    SELECT 
        transaction_date,
        SUM(total_spent) AS total_sales
    FROM orders_cafe
	GROUP BY transaction_date
) daily_sales
ORDER BY transaction_date;

---------------------------------WEEKDAY VS WEEKEND---------------------------------
-- Which product is the best-selling for each order type?
WITH sales_by_day AS(
SELECT
	product_name,
	SUM(total_spent) total_sales,
	FORMAT(transaction_date, 'dddd') day_name
FROM orders_cafe
GROUP BY product_name,
FORMAT(transaction_date, 'dddd')
)
SELECT
product_name,
CASE 
	WHEN day_name IN ('Saturday', 'Sunday') THEN 'Weekend'
	ELSE 'Weekday'
END AS category_day,
total_sales
FROM sales_by_day;

---------------------------------RANKING ANALYSIS---------------------------------
 -- Which product has the highest number of transactions for each order type
WITH ranked_products AS (
  SELECT 
    order_type,
    product_name,
    COUNT(*) AS total_transactions,
    ROW_NUMBER() OVER (
      PARTITION BY order_type 
      ORDER BY COUNT(*) DESC
    ) AS rn
  FROM orders_cafe
  GROUP BY order_type, product_name
)
SELECT 
  order_type,
  product_name AS best_selling_product,
  total_transactions
FROM ranked_products
WHERE rn = 1;
 
 -- Which product ranks highest revenue
SELECT *
FROM (
  SELECT product_name,
  SUM(total_spent) total_sales,
  RANK() OVER (ORDER BY SUM(total_spent)) AS rank_product
  FROM orders_cafe
  GROUP BY product_name
) ranked_products
ORDER BY rank_product DESC;

-- Which product is the most frequently purchased for each payment method
WITH rank_payment AS (
  SELECT 
    payment_method,
    product_name AS best_selling_product,
    COUNT(*) AS total_transactions,
    SUM(total_spent) AS total_sales
  FROM orders_cafe
  GROUP BY payment_method, product_name
)
,
payment AS (
  SELECT
   payment_method,
   best_selling_product,
   total_transactions,
   total_sales,
   ROW_NUMBER() OVER (PARTITION BY payment_method  ORDER BY total_transactions DESC ) AS rn
   FROM rank_payment
)
SELECT 
  payment_method,
  best_selling_product,
  total_transactions,
  total_sales
FROM payment
WHERE rn = 1;



---------------------------------PERFORMANCE ANALYSIS---------------------------------

-- How does each product's monthly sales change over time compared to previous month and average
WITH monthly_product_sales AS (
	SELECT
		MONTH(transaction_date) AS order_month,
		product_name,
		SUM(total_spent) AS current_sales
	FROM orders_cafe
	GROUP BY 
	product_name, 
	MONTH(transaction_date)
)
SELECT
	order_month,
	product_name,
	current_sales,
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) pm_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) diff_pm,
	CASE
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) < 0 THEN 'decrease'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) > 0 THEN 'increase'
		ELSE 'no change'
	END AS mom_status,
	AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below AVG'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above AVG'
		ELSE 'avg'
	END AS avg_change
FROM monthly_product_sales
ORDER BY product_name, order_month;


---------------------------------CUMULATIVE ANALYSIS---------------------------------

-- How do you calculate the cumulative total sales and moving average price based on transaction date
WITH running_sales AS(
SELECT
	DATETRUNC(month, transaction_date) transaction_date,
	SUM(total_spent) total_sales,
	AVG(price) avg_price
	FROM orders_cafe
	GROUP BY DATETRUNC(month, transaction_date)
)
SELECT
	transaction_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY transaction_date) running_total_sales,
	avg_price,
	AVG(avg_price) OVER (ORDER BY transaction_date) moving_average
	FROM running_sales;

-- How to compute the moving average of product prices by transaction month
SELECT
	transaction_date,
	avg_price,
	AVG(avg_price) OVER (ORDER BY transaction_date) moving_average
FROM(
SELECT
	DATETRUNC(month, transaction_date) transaction_date,
	AVG(price) avg_price
	FROM orders_cafe
	GROUP BY DATETRUNC(month, transaction_date)
) moving_average;



-- ========================= Parameters in Stored Procedure =========================

-- Define Stored Procedure
IF OBJECT_ID('GetOrderSummaryByProduct', 'P') IS NOT NULL
    DROP PROCEDURE GetOrderSummaryByProduct;
GO
CREATE PROCEDURE GetOrderSummaryByProduct AS
BEGIN
	SELECT 
        COUNT(*) total_product ,
        AVG(total_spent) avg_product,
        SUM(total_spent) total_sales
	FROM orders_cafe
END
GO


-- Performance for a Specific Product

ALTER PROCEDURE GetOrderSummaryByProduct  @product_name NVARCHAR(50) = 'cake' AS
BEGIN
    -- Deklarasi Variabel
    DECLARE @total_product INT,
            @avg_product DECIMAL(10,2),
            @total_sales DECIMAL(10,2);

    -- Fetch Data
    SELECT
        @total_product = COUNT(*),
        @avg_product = AVG(total_spent),
        @total_sales = SUM(total_spent)
    FROM orders_cafe
	WHERE product_name = @product_name;

	-- Output message
	PRINT 'Sales Summary for Product:' + @product_name;
	PRINT 'Total Number of Orders:' + CAST(@total_product AS NVARCHAR);
	PRINT 'Average Purchase Value:' + CAST(@avg_product AS NVARCHAR);
	PRINT 'Total Sales Value:' + CAST(@total_sales AS NVARCHAR);

	SELECT 
        @product_name AS product_name,
        @total_product AS total_product,
        @avg_product AS avg_product,
        @total_sales AS total_sales;

END
GO
;

-- Execute Stored Procedure
EXEC GetOrderSummaryByProduct;
EXEC GetOrderSummaryByProduct @product_name = 'coffee';
EXEC GetOrderSummaryByProduct @product_name = 'sandwich';
EXEC GetOrderSummaryByProduct @product_name = 'juice';
EXEC GetOrderSummaryByProduct @product_name = 'tea';
EXEC GetOrderSummaryByProduct @product_name = 'salad';
EXEC GetOrderSummaryByProduct @product_name = 'cookie';
