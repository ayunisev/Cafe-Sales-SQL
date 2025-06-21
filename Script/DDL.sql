/*
DDL Script : Create Database and Sales table

Script Purpose :
This script creates a new database name 'SalesCafe' and creates table in the 'transaction_cafe', dropping existing tables if they already exist.
==============================================================================================
------------------------------------DATA DEFINITION LANGUAGE (DDL) ------------------------------------
==============================================================================================
*/


-- DROP and recreate the 'SalesCafe' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SalesCafe')
BEGIN
	ALTER DATABASE SalesCafe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE SalesCafe;
END;
GO

-- Create the 'SalesCafe' database
CREATE DATABASE SalesCafe;
GO

-- Create Table transaction_cafe
IF OBJECT_ID('transaction_cafe', 'U') IS NOT NULL
    DROP TABLE transaction_cafe;
GO


CREATE TABLE transaction_cafe(
Transaction_ID nvarchar(50),
Product_name nvarchar(50),
Quantity int,
Price Decimal (10,2),
Total_Spent Decimal (10,2),
Payment_Method nvarchar(50),
Order_Type nvarchar(50),
Transaction_Date DATE,
)

TRUNCATE TABLE transaction_cafe;
GO

BULK INSERT transaction_cafe
FROM 'C:\SQL\DataCafe\cafe_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

