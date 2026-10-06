--                              Data Analysis Project
--                          1] Change-Over-Time'Trends'
-->
-- 1]Analyze Sales Performance Over Time
SELECT
	YEAR(order_date) AS Order_Year,
	MONTH(order_date) AS Order_Month,
	SUM(sales_amount) AS TotalSales,
	COUNT(DISTINCT customer_key) AS TotalCustomers,
	SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR(order_date),
	MONTH(order_date)
ORDER BY 
	YEAR(order_date),
	MONTH(order_date);

-- Same Solution – Different Approach
SELECT
	DATETRUNC(MONTH, order_date) AS OrderDate,
	SUM(sales_amount) AS TotalSales,
	COUNT(DISTINCT customer_key) AS TotalCustomers,
	SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	DATETRUNC(MONTH, order_date)
ORDER BY 
	DATETRUNC(MONTH, order_date);

-- Same Solution – Different Approach
SELECT
	 FORMAT(order_date, 'yyyy-MMM') AS OrderDate,
	SUM(sales_amount) AS TotalSales,
	COUNT(DISTINCT customer_key) AS TotalCustomers,
	SUM(quantity) AS TotalQuantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	FORMAT(order_date, 'yyyy-MMM')
ORDER BY 
	FORMAT(order_date, 'yyyy-MMM');


--                          2] Cumulative Analysis
-->
-- 2] Calculate the total sales per month
--    and the running total of sales over time
SELECT
	*,
	SUM(TotalSales) OVER(ORDER BY Order_Month) AS Running_Total_Sales
FROM
(
	SELECT 
		DATETRUNC(MONTH,order_date) AS Order_Month,
		SUM(sales_amount) AS TotalSales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	Group by DATETRUNC(MONTH,order_date); 
)T

-- 3] Calculate the total sales per year
--    and the running total of sales over time
SELECT
*,
SUM(Total_Sales) OVER (ORDER BY Order_Year) AS Running_Total_Sales
FROM
(
	SELECT
		YEAR (order_date) AS Order_Year,
		SUM(sales_amount) AS Total_Sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR (order_date);
)T

--                          2] Performance Analysis
-->
/* 4] Analyze the yearly performance of products by comparing their sales
	  to both the average sales performance of the product and the previous years's sales */
WITH Yearly_Product_Sales AS
(
	SELECT
		year(F.order_date) AS Order_Year,
		P.product_name,
		SUM(sales_amount) AS Current_Sales
	FROM gold.fact_sales F
	LEFT JOIN gold.dim_products P
	ON F.product_key = P.product_key
	WHERE F.order_date IS NOT NULL
	GROUP BY 
		year(F.order_date),
		P.product_name
)
SELECT
	Order_Year,
	product_name,
	Current_Sales,
	AVG(Current_Sales) OVER(PARTITION BY product_name) AS Avg_Sales,
	Current_Sales - AVG(Current_Sales) OVER(PARTITION BY product_name) AS Diff_Avg,
	CASE 
		WHEN Current_Sales - AVG(Current_Sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN Current_Sales - AVG(Current_Sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END AS Avg_Change,
	LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_Year) AS PY_Sales,
	Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_Year) AS Diff_PY,
	CASE 
		WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_Year) > 0 THEN 'Increase'
		WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY Order_Year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS PY_Change
FROM Yearly_Product_Sales

--                          3] Part_To_Whole Analysis
-->
-- 5] Which Category Contribute The Most Overall Sales
With Category_Sales AS
(
	SELECT
		P.category,
		SUM(sales_amount) AS Total_Sales
	FROM gold.fact_sales F
	LEFT JOIN gold.dim_products P
	ON F.product_key = P.product_key
	GROUP BY P.category
)
SELECT
	category,
	Total_Sales,
	SUM(Total_Sales) OVER() AS Overall_Sales,
	CONCAT(ROUND(CAST(Total_Sales AS FLOAT) / SUM(Total_Sales) OVER() * 100, 2), '%') AS Percentage_of_Total
FROM Category_Sales
ORDER BY Total_Sales DESC;

--                          4] Data Segmentation
-->
-- 6] Segment Products into Cost Ranges and Count How Many Products Fall into Each Segment.
WITH Products_Segments AS
(
	SELECT 
		product_key,
		product_name,
		cost,
		CASE
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS Cost_Range
	FROM gold.dim_products
)
SELECT
Cost_Range,
COUNT(product_key) AS Total_Products
FROM Products_Segments
GROUP BY Cost_Range
ORDER BY Total_Products DESC

/* 7] Group Customers into Three Segments Based On Their Spendinf Behavior:
		- VIP: Customers With at Least 12 Months of History And Spending More Than 5,000.
		- Regular : Customers  With at Least 12 Months of History But Spending 5,000 or Less.
		- New: Customer With a Lifespan Less Than 12 Months 
	  And Find The Total Number Of Customers By Each Group */
WITH Customer_Spending AS
(
	SELECT
		C.customer_key,
		SUM(F.sales_amount) AS Total_Sales,
		MIN(F.order_date) AS First_Order,
		MAX(F.order_date) AS Last_Order,
		DATEDIFF(MONTH, MIN(F.order_date), MAX(F.order_date) ) AS Lifespan
	FROM gold.fact_sales F
	LEFT JOIN gold.dim_customers C
	ON F.customer_key = C.customer_key
	GROUP BY C.customer_key
)
SELECT
Customer_Segment,
COUNT(customer_key) AS Total_Customers
FROM
(
	SELECT
		customer_key,
		Total_Sales,
		Lifespan,
		CASE
			WHEN Lifespan >= 12 AND Total_Sales > 5000 THEN 'VIP'
			WHEN Lifespan >= 12 AND Total_Sales <= 5000 THEN 'Regular'
			ELSE 'New'
	END AS Customer_Segment
	FROM Customer_Spending
)t
	GROUP BY Customer_Segment
	ORDER BY Total_Customers DESC;

/*
===========================================================================
Customer Report
===========================================================================
Purpose:
	-This report consolidates key customer metrics and behaviors
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
	- total orders
	- total sales
	- total quantity purchased
	- total products
	- lifespan (in months)
4. Calculates valuable KPIs:
	- recency (months since last order)
	- average order value
	- average monthly spend
*/
============================================================================
SELECT
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
c.first_name,
c.last_name,
c.birthdate
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key

