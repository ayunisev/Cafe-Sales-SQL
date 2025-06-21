![image](https://github.com/user-attachments/assets/d2bf071a-9504-4450-92f8-2a6004538fd9)

![image](https://github.com/user-attachments/assets/d4c4fe4c-9a54-4223-b31a-7f96807790fe) **About the Project**
This project focuses on analyzing transactional sales data collected from a cafe using structured SQL queries. 
It demonstrates how SQL can be used not just for querying data but for performing comprehensive data analysis including aggregation, ranking, trend analysis, and categorization. 
By transforming raw sales data into actionable insights, this project aims to assist cafe management in making strategic decisions based on real-time sales patterns and historical performance.
--
![image](https://github.com/user-attachments/assets/25c14ff3-0230-41ef-b124-d0d17d5ad5a8) **Dataset**
this dataset uses from kaggle
[Cafe Sales Data](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training)
--
 ![image](https://github.com/user-attachments/assets/26cb16f8-be38-4a29-bf26-c02f80eccbdd) **Purpose of the Project**
The primary goals of this project are to:
•	Conduct EDA using SQL queries.
•	Extract actionable business insights from sales data.
•	Visualize patterns related to sales, product performance, and customer behavior.
•	Improve strategic business decisions based on historical performance.
--
![image](https://github.com/user-attachments/assets/a64f1748-3b29-48b1-bb8f-07208117fec0) **SQL Techniques Used** :
•	Data Cleaning: ISNULL(), COALESCE(), CASE, conditional logic
•	Transformation & Calculation: NULLIF(), arithmetic
•	Aggregations & Windowing: SUM(), AVG(), MIN(), MAX(), LAG(), LEAD(), RANK(), ROW_NUMBER()
•	Time Functions: FORMAT(), DATETRUNC(), MONTH()
--
![image](https://github.com/user-attachments/assets/931d160b-295b-47e8-b517-700fad8a60af) **Data Cleaning & Transformation Objectives**:
•	Clean Null or Inconsistent Fields:
  Fill missing product_name based on price.
  Fill missing price based on known product_name.
•	Recalculate and Fix Invalid Values:
  Recalculate quantity or price using total_spent when missing or zero.
  Recompute total_spent as quantity * price.
•	Standardize Missing Text or Dates:
  Replace NULL in payment_method, order_type, and transaction_date with default placeholders.
•	Validate Input:
  Insert only complete and logically correct rows into orders_cafe.
--
![image](https://github.com/user-attachments/assets/9090d651-1e8b-4221-b4ba-7b64a280f463) **Exploratory Data Analysis (EDA)**
The script covers:
•	Basic Metrics: Total, average, highest, and lowest sales.
•	Sales Breakdown: By product, payment method, and order type.
•	Top Performers: Highest revenue and quantity.
•	Temporal Trends: Daily, weekday/weekend, and monthly patterns.
•	Comparative Insights: Sales compared to benchmarks.
•	Sales Buckets: Categorizing performance into low, medium, and high.
•	Ranking Analysis: Product performance across order types and payment methods.
•	Cumulative and Moving Average: Monthly cumulative trends and moving averages.
•	Stored Procedures: Custom procedures to retrieve summary data for specific products.
--


