                                                 -- EDA PROJECT--
--                                            [1] DATABASE EXPLORATION
-->
-- 1] Explore All Tables in the Database
SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES;

--                                       2] Explore ALL Columns in the Database
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    ORDINAL_POSITION 
FROM INFORMATION_SCHEMA.COLUMNS

--                                              3] Explore Row Counts
SELECT
    t.name AS Table_Name,
    SUM(p.rows) AS Row_Count
FROM sys.tables t
INNER JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY Row_Count DESC;

--                                            4] DATA QUALITY EXPLORATION
-->
-- 1. Check NULL Values Across All Tables
DECLARE @SQL NVARCHAR(MAX) = '';
SELECT @SQL +=
    'SELECT ''' + TABLE_NAME + ''' AS Table_Name, ' +
    '''' + COLUMN_NAME + ''' AS Column_Name, ' +
    'COUNT(*) - COUNT([' + COLUMN_NAME + ']) AS Null_Count ' +
    'FROM [' + TABLE_NAME + '] UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS;
SET @SQL = LEFT(@SQL, LEN(@SQL) - 10);
EXEC sp_executesql @SQL;

-- NULL meanings according to the dataset documentation:
-- categories.parent_category_id → Top-level category with no parent category
-- customers.loyalty_tier        → Customer is not enrolled in the loyalty program
-- products.discontinued_at      → Product is still on sale
-- orders.coupon_code            → No coupon was used for the order
-- orders.shipped_at             → Order has not been shipped yet or was cancelled
--
-- These NULL values are intentional and do not require data imputation.
-- For analysis, they will be replaced with descriptive labels when appropriate,
-- without modifying the original data.
--
-- The meaning of payments.failure_reason is not specified in the documentation,
-- so it will be investigated separately.
------------------------------------------------------------------------

-- 2. Analyze Payment Failure Reasons by Payment Status
 SELECT
 *
 FROM payments
-- Note: Successful payments have NULL values in the failure_reason column,
-- while failed payments contain the corresponding failure reason.
--------------------------------------------------------------------------

--                                            4]  CUSTOMERS EDA
--                                         1] DIMENSIONS EXPLORATION
-->                                                               
-- 1. Explore Customer Countries
SELECT
    DISTINCT country
FROM customers;

-- 2. Explore Customer Cities
SELECT
    DISTINCT city
FROM customers;

-- 3. Explore Customer Loyalty Tiers
SELECT
    DISTINCT loyalty_tier
FROM customers;

-- 4. Explore Customer Marketing Preferences
SELECT
   DISTINCT marketing_opt_in
FROM customers;

--                                         2] DATE EXPLORATION
-->
-- 5. Explore Customer Signup Date Range
-- How many years and months of customer signup data are available
SELECT
    MIN(signup_date) AS First_Signup_Date,
    MAX(signup_date) AS Last_Signup_Date,
    DATEDIFF(YEAR, MIN(signup_date), MAX(signup_date)) Signup_Range_Year,
    DATEDIFF(MONTH, MIN(signup_date), MAX(signup_date)) Signup_Range_Month
FROM customers;


--                                         3] MEASURES EXPLORATION
-->
-- 6.Find the total number of customers
SELECT COUNT(customer_id) AS Total_Customers FROM customers;

--                                         4] MAGNITUDE ANALYSIS
-->
-- 7. Compare Customers Across Countries
SELECT
    country,
    COUNT(customer_id) AS Total_Customer
FROM customers
GROUP BY country
ORDER BY Total_Customer DESC;

-- 8. Compare Customers Across Loyalty Tiers
SELECT
    ISNULL(loyalty_tier,  'Not Enrolled in Loyalty Program') AS Loyalty_Tier,
    COUNT(customer_id) AS Total_Customers
FROM customers
GROUP BY ISNULL(loyalty_tier,  'Not Enrolled in Loyalty Program')
ORDER BY Total_Customers DESC;

-- 9. Compare Customers by Marketing Preference
SELECT
    CASE
        WHEN marketing_opt_in = 1 THEN 'Opted In'
        ELSE 'Opted Out'
    END AS Marketing_Preference,
    COUNT(customer_id) AS Total_Customers
FROM customers
GROUP BY
    CASE
        WHEN marketing_opt_in = 1 THEN 'Opted In'
        ELSE 'Opted Out'
    END
ORDER BY Total_Customers DESC;

--                                         5] RANKING ANALYSIS
-->
-- 10. Find the Top 10 Customers by Total Number of Orders
SELECT TOP 10
    C.customer_id,
    C.first_name,
    C.last_name,
    FORMAT(COUNT(O.order_id), 'N0') AS Total_Orders
FROM orders O 
LEFT JOIN customers C
ON O.customer_id = C.customer_id
GROUP BY 
    C.customer_id,
    C.first_name,
    C.last_name
ORDER BY COUNT(O.order_id) DESC

-- 11. Find the Customers Who Made Only 1 Order
SELECT 
    C.customer_id,
    C.first_name,
    C.last_name,
    COUNT(O.order_id) AS Total_Orders
FROM orders O 
LEFT JOIN customers C
ON O.customer_id = C.customer_id
GROUP BY 
    C.customer_id,
    C.first_name,
    C.last_name
HAVING COUNT(O.order_id) = 1

-- 12. Find the Top 10 Customers Who Generated the Highest Revenue
SELECT TOP 10
    C.customer_id,
    C.first_name,
    C.last_name,
    FORMAT(SUM(OI.quantity * OI.unit_price - OI.discount_amount), 'N0') AS Total_Revenue
FROM order_items OI
LEFT JOIN orders O
    ON OI.order_id = O.order_id
LEFT JOIN customers C
    ON O.customer_id = C.customer_id
GROUP BY
    C.customer_id,
    C.first_name,
    C.last_name
ORDER BY
    SUM(OI.quantity * OI.unit_price - OI.discount_amount) DESC;

--                                            4]  PRODUCTS EDA
--                                         1] DIMENSIONS EXPLORATION
-->
-- 13. Explore Product Categories
SELECT
    C.category_name,
    p.product_name
FROM categories C
INNER JOIN products P
ON C.category_id = P.category_id
ORDER BY 
    C.category_name,
    p.product_name;


-- 14. Explore Product Discontinued Status
SELECT
    CASE
        WHEN discontinued_at IS NULL THEN 'Still On Sale'
        ELSE 'Discontinued'
    END AS Product_Status,
    COUNT(product_id) AS Total_Products
FROM products
GROUP BY 
     CASE
        WHEN discontinued_at IS NULL THEN 'Still On Sale'
        ELSE 'Discontinued'
    END;


--                                         2] DATE EXPLORATION
-->
-- 15. Analyze How Long Products Have Been Discontinued
SELECT
    product_id,
    product_name,
    discontinued_at,
DATEDIFF(YEAR,discontinued_at,GETDATE()) AS Years_Since_Discontinued
FROM products
WHERE discontinued_at IS NOT NULL
ORDER BY Years_Since_Discontinued DESC;


--                                         3] MEASURES EXPLORATION
-->
-- 16. Calculate Total Number of Products
SELECT
    COUNT(*) AS Total_Products
FROM Products;

-- 17. Calculate Average Product Price
SELECT
    AVG(unit_price) AS Avg_Unit_Price
FROM Products

-- 18. Calculate Average Product Cost
SELECT
    AVG(unit_cost) AS Avg_Unit_Price
FROM Products

-- 19. Calculate Average Product Profit Margin

SELECT
    AVG(
        (unit_price - unit_cost) / NULLIF(unit_price, 0) * 100
    ) AS Average_Profit_Margin
FROM products;

--                                         4] MAGNITUDE ANALYSIS
-->
-- 20. Compare Products Across Categories
SELECT
C.category_name,
COUNT(P.product_id) AS Total_Products
FROM categories C
INNER JOIN products P
ON C.category_id = P.category_id
GROUP BY C.category_name;

-- 21. Compare Product Profit Margin Across Categories
SELECT
    C.category_name,
    CAST(
        ROUND(
            AVG(
                (P.unit_price - P.unit_cost) / NULLIF(P.unit_price, 0) * 100
            ),
            2
        ) AS DECIMAL(10,2)
    ) AS Average_Profit_Margin
FROM categories C
INNER JOIN products P
ON C.category_id = P.category_id
GROUP BY 
    C.category_name
ORDER BY
    Average_Profit_Margin DESC;

-- 22. Compare Average Product Cost Across Categories
 SELECT
    C.category_name,
    AVG(P.unit_cost) AS Avg_Unit_Cost
FROM categories C
INNER JOIN products P
ON C.category_id = P.category_id
GROUP BY
    C.category_name
ORDER BY
    Avg_Unit_Cost DESC;

-- 23. Compare Total Sales Across Products
SELECT
    P.product_id,
    P.product_name,
    FORMAT(SUM(OI.quantity*OI.unit_price-OI.discount_amount), 'N0') Total_Revenue
FROM order_items OI
INNER JOIN products P 
ON OI.product_id = P.product_id
GROUP BY 
    P.product_id,
    P.product_name
ORDER BY  SUM(OI.quantity*OI.unit_price-OI.discount_amount) DESC;


--                                         5] RANKING ANALYSIS
-->
-- 24. Find the Top 10 Products by Total Revenue
SELECT TOP 10
    P.product_id,
    P.product_name,
    FORMAT(SUM(OI.quantity*OI.unit_price-OI.discount_amount), 'N0') Total_Revenue
FROM order_items OI
INNER JOIN products P 
ON OI.product_id = P.product_id
GROUP BY 
    P.product_id,
    P.product_name
ORDER BY  SUM(OI.quantity*OI.unit_price-OI.discount_amount) DESC;

-- 25. Find the Top 10 Products by Total Quantity Sold
SELECT TOP 10
    P.product_id,
    P.product_name,
    FORMAT(SUM(OI.quantity), 'N0') Total_Quantity
FROM order_items OI
INNER JOIN products P 
ON OI.product_id = P.product_id
GROUP BY 
    P.product_id,
    P.product_name
ORDER BY  SUM(OI.quantity) DESC;

-- 25. Find the Top 10 Products by Total Profit

SELECT TOP 10
    P.product_id,
    P.product_name,
    FORMAT(
        SUM(
            (OI.quantity * OI.unit_price)
            - OI.discount_amount
            - (OI.quantity * P.unit_cost)
        ),
        'N0'
    ) AS Total_Profit
FROM order_items OI
INNER JOIN products P
    ON OI.product_id = P.product_id
GROUP BY
    P.product_id,
    P.product_name
ORDER BY
    SUM(
        (OI.quantity * OI.unit_price)
        - OI.discount_amount
        - (OI.quantity * P.unit_cost)
    ) DESC;


--                                            4] CATEGORIES EDA
--                                         1] DIMENSIONS EXPLORATION
-->
-- 26. Explore Category Hierarchy
SELECT
    Child.category_name As Category,
    Parent.category_name AS Parent_Category
FROM categories Child
LEFT JOIN categories Parent
ON Child.parent_category_id = Parent.category_id
ORDER BY 
    Parent.category_name,
    Child.category_name;
 

--                                         2] MEASURES EXPLORATION
-->
-- 27. Calculate Total Number of Top-Level Categories
SELECT
    COUNT(category_id) Total_Categories
FROM categories
WHERE parent_category_id IS NULL;

-- 28. Calculate Total Number of All Categories
SELECT
    COUNT(category_id) Total_Categories
FROM categories

--                                         3] MAGNITUDE ANALYSIS
-->
-- 29. Compare Top-Level Categories by Number of Subcategories

SELECT
    Parent.category_name AS Top_Level_Category,
    COUNT(Child.category_id) AS Total_Subcategories
FROM categories Parent
LEFT JOIN categories Child
    ON Child.parent_category_id = Parent.category_id
WHERE Parent.parent_category_id IS NULL
GROUP BY
    Parent.category_name
ORDER BY
    Total_Subcategories DESC;

-- 30. Compare Total Revenue Across Categories
SELECT
    C.category_id,
    C.category_name,
    FORMAT(SUM(OI.unit_price * OI.quantity - OI.discount_amount), 'N0') AS Total_Revenue
FROM order_items OI
INNER JOIN products P
ON OI.product_id = P.product_id
INNER JOIN categories C
ON P.category_id = C.category_id
GROUP BY 
    C.category_id,
    C.category_name
ORDER BY 
    SUM(OI.unit_price * OI.quantity - OI.discount_amount) DESC;

-- 31. Compare Total Profit Across Categories
SELECT
    C.category_id,
    C.category_name,
   FORMAT(
       SUM(
            (OI.unit_price * OI.quantity)
            - OI.discount_amount
            - (P.unit_cost * OI.quantity)
            ), 'N0'
        ) AS Total_Profit
FROM order_items OI
INNER JOIN products P
ON OI.product_id = P.product_id
INNER JOIN categories C
ON P.category_id = C.category_id
GROUP BY 
    C.category_id,
    C.category_name
ORDER BY 
    SUM(
         (OI.unit_price * OI.quantity)
        - OI.discount_amount
        - (P.unit_cost * OI.quantity)
       ) DESC;

-- 32. Compare Total Cost Across Categories
SELECT
    C.category_id,
    C.category_name,
    FORMAT(SUM(P.unit_cost * OI.quantity), 'N0') AS Total_Cost
FROM order_items OI
INNER JOIN products P
ON OI.product_id = P.product_id
INNER JOIN categories C
ON P.category_id = C.category_id
GROUP BY 
    C.category_id,
    C.category_name
ORDER BY 
    SUM(P.unit_cost * OI.quantity) DESC;

-- 33. Compare Total Quantity Sold Across Categories
SELECT
    C.category_id,
    C.category_name,
    FORMAT(SUM(OI.quantity), 'N0') AS Total_Quantity
FROM order_items OI
INNER JOIN products P
ON OI.product_id = P.product_id
INNER JOIN categories C
ON P.category_id = C.category_id
GROUP BY 
    C.category_id,
    C.category_name
ORDER BY 
    SUM(OI.quantity) DESC;


--                                         4] RANKING ANALYSIS
-->
-- 34. Find the Top 10 Categories by Total Revenue
SELECT TOP 10
    C.category_id,
    C.category_name,
    FORMAT(SUM(OI.unit_price * OI.quantity - OI.discount_amount), 'N0') AS Total_Revenue
FROM order_items OI
INNER JOIN products P
ON OI.product_id = P.product_id
INNER JOIN categories C
ON P.category_id = C.category_id
GROUP BY 
    C.category_id,
    C.category_name
ORDER BY 
    SUM(OI.unit_price * OI.quantity - OI.discount_amount) DESC;

--                                            5] PAYMENTS EDA
--                                         1] DIMENSIONS EXPLORATION
-->
-- 35. Explore Payment Methods
SELECT 
    DISTINCT(method)
FROM payments

-- 36. Explore Payment Status
SELECT
    DISTINCT(status)
FROM payments

-- 37. Explore Payment Failure Reasons
SELECT 
    DISTINCT ISNULL(failure_reason, 'No Failure') AS Failure_Reason
FROM payments;

--                                         2] MEASURES EXPLORATION
-->
-- 38. Calculate Total Number of Payments
SELECT
    COUNT(*) AS Total_Payments
FROM payments

SELECT
*
FROM payments

-- 39. Calculate Total Payment Amount
SELECT
    FORMAT(CAST(SUM(amount) AS DECIMAL(18,0)), 'N0') AS Total_Payment_Amount
FROM payments;

-- 40. Calculate Total Captured Payment Amount
SELECT
    FORMAT(CAST(SUM(amount) AS DECIMAL(18,0)), 'N0') AS Total_Payment_Amount
FROM payments
WHERE status = 'captured'

-- 41. Calculate Total Failed Payment Amount
SELECT
    FORMAT(CAST(SUM(amount) AS DECIMAL(18,0)), 'N0') AS Total_Payment_Amount
FROM payments
WHERE status = 'failed'

--                                         3] MAGNITUDE ANALYSIS
-->
-- 42. Compare Total Payments Across Payment Methods
SELECT
    method,
    COUNT(*) AS Total_Payments
FROM payments
GROUP BY 
    method
ORDER BY Total_Payments DESC;

-- 43. Compare Total Payment Amount Across Payment Methods
SELECT
    method,
    SUM(amount) AS Total_Payment_Amount
FROM payments
GROUP BY 
    method
ORDER BY
    Total_Payment_Amount DESC;

-- 44. Compare Total Failed Payment Amount Across Payment Methods
SELECT
    method,
    SUM(amount) AS Total_Failed_Payment_Amount
FROM payments
WHERE status = 'failed'
GROUP BY 
    method
ORDER BY
    Total_Failed_Payment_Amount DESC;

-- 45. Compare Total Payment Amount Across Payment Statuses
SELECT
    status,
    SUM(amount) AS Total_Payment_Amount
FROM payments
GROUP BY 
   status
ORDER BY
    Total_Payment_Amount DESC;

-- 46. Compare Payment Failure Reasons
SELECT
    CASE
        WHEN failure_reason IS NULL THEN 'No Failure'
        ELSE failure_reason
    END AS Payment_Failure_Reason,
    COUNT(*) AS Total_Payment
FROM payments
GROUP BY 
    CASE
        WHEN failure_reason IS NULL THEN 'No Failure'
        ELSE failure_reason
    END
ORDER BY 
    Total_Payment DESC;

--                                            6] RETURNS EDA
--                                         1] DIMENSIONS EXPLORATION
-->
-- 47. Explore Return Reasons
SELECT
    DISTINCT(reason) 
FROM returns


--                                         2] MEASURES EXPLORATION
-->
-- 48. Calculate Total Number of Returns
SELECT
    COUNT(*) Total_Returns
FROM returns

-- 49. Calculate Total Refund Amount
SELECT
    SUM(refund_amount) AS Total_Refund_Amount
FROM returns

-- 50. Calculate Average Refund Amount
SELECT
    CAST(AVG(refund_amount) AS DECIMAL(18,2)) AS Average_Refund_Amount
FROM returns;

-- 51. Calculate Total Restocked Items
SELECT
    COUNT(restocked) Total_Restocked_Items
FROM returns
WHERE restocked = 1

-- 52. Calculate Total Non-Restocked Items
SELECT
    COUNT(restocked) Total_Non_Restocked_Items
FROM returns
WHERE restocked = 0;

--                                         3] MAGNITUDE ANALYSIS
-->
-- 53. Compare Total Refund Amount by Return Reason
SELECT 
    reason,
    SUM(refund_amount) AS Total_Refund_Amount
FROM returns
GROUP BY 
    reason
ORDER BY 
    Total_Refund_Amount DESC;

-- 54. Compare Total Returns by Return Reason
SELECT 
    reason,
    COUNT(*) AS Total_Returns
FROM returns
GROUP BY 
    reason
ORDER BY 
    Total_Returns DESC;

-- 55. Compare Total Refund Amount by Restock Status
SELECT
    CASE
        WHEN restocked = 1 THEN 'Restocked'
        ELSE 'Non Restocked'
    END AS Restock_Status,
    SUM(refund_amount) AS Total_Refund_Amount
FROM returns
GROUP BY    
    CASE
        WHEN restocked = 1 THEN 'Restocked'
        ELSE 'Non Restocked'
    END
ORDER BY
    Total_Refund_Amount DESC;
    
-- 56. Compare Total Returns by Restock Status
SELECT
    CASE
        WHEN restocked = 1 THEN 'Restocked'
        ELSE 'Non Restocked'
    END AS Restock_Status,
    COUNT(*) AS Total_Returns
FROM returns
GROUP BY    
    CASE
        WHEN restocked = 1 THEN 'Restocked'
        ELSE 'Non Restocked'
    END
ORDER BY
    Total_Returns DESC;

--                                             7] ORDER_ITEMS EDA
--                                           1] MEASURES EXPLORATION
-->\
-- 57. Calculate Total Number of Order Items
SELECT
COUNT(order_item_id) AS Total_Order_Items
FROM  order_items

-- 58. Calculate Total Quantity Sold
SELECT
    SUM(quantity) AS Total_Quantity_Sold
FROM order_items;

-- 59. Calculate Total Revenue from Order Items
SELECT
    SUM(unit_price*quantity - discount_amount) Total_Revenue
FROM order_items

-- 60. Calculate Total Discount Amount
SELECT
    SUM(discount_amount) AS Total_Discount_Amount
FROM order_items;

-- 61. Calculate Total Cost from Order Items

SELECT
    SUM(P.unit_cost * OI.quantity) AS Total_Cost
FROM order_items OI
INNER JOIN products P
    ON OI.product_id = P.product_id;

-- 62. Calculate Total Profit from Order Items

SELECT
    SUM(
        (OI.unit_price * OI.quantity)
        - OI.discount_amount
        - (P.unit_cost * OI.quantity)
    ) AS Total_Profit
FROM order_items OI
INNER JOIN products P
    ON OI.product_id = P.product_id;

--                                             8] ORDER_ITEMS EDA
--                                           1] DIMENSIONS EXPLORATION
-->
-- 63. Explore Order Status
SELECT
    DISTINCT status
FROM orders;

-- 64. Explore Order Channels
SELECT
    DISTINCT channel
FROM orders

--                                         2] DATE EXPLORATION
-->
-- 65. Explore Order Date Range
SELECT
    MIN(ordered_at) First_Order_Date,
    MAX(ordered_at) Last_Order_Date
FROM orders

-- 66. Explore Order Years
SELECT DISTINCT
    YEAR(ordered_at) AS Order_Year
FROM orders
ORDER BY
    Order_Year;

--                                         3] MEASURES EXPLORATION
-->
-- 67. Calculate Total Number of Orders
SELECT
    COUNT(*) AS Total_Orders
FROM orders

-- 68. Calculate Average Order Value
SELECT
    CAST(
        SUM((unit_price * quantity) - discount_amount)
        / COUNT(DISTINCT order_id)
        AS DECIMAL(18,2)
    ) AS Average_Order_Value
FROM order_items ;

-- 69. Calculate Average Items per Order
SELECT
    CAST(COUNT(order_item_id) AS DECIMAL(18,2))
    / COUNT(DISTINCT order_id) AS Average_Items_Per_Order
FROM order_items;

--                                         4] MAGNITUDE ANALYSIS
-->
-- 70. Compare Total Orders by Order Status
SELECT
    status,
    COUNT(*) AS Total_Orders
FROM orders
GROUP BY 
    status
ORDER BY
    Total_Orders DESC;

-- 71. Compare Total Orders by Order Channel
SELECT
    channel,
    COUNT(*) AS Total_Orders
FROM orders
GROUP BY 
    channel
ORDER BY
    Total_Orders DESC;

-- Generate a report that shows all key metrics of business
SELECT 'Total Top-Level Categories' AS Measure_Name, FORMAT(COUNT(category_id), 'N0') AS Measure_Value
FROM categories
WHERE parent_category_id IS NULL

UNION ALL
SELECT 'Total Categories', FORMAT(COUNT(category_id), 'N0')
FROM categories

UNION ALL
SELECT 'Total Payments', FORMAT(COUNT(*), 'N0')
FROM payments

UNION ALL
SELECT 'Total Payment Amount', FORMAT(SUM(amount), 'N2')
FROM payments

UNION ALL
SELECT 'Total Captured Payment Amount', FORMAT(SUM(amount), 'N2')
FROM payments
WHERE status = 'captured'

UNION ALL
SELECT 'Total Failed Payment Amount', FORMAT(SUM(amount), 'N2')
FROM payments
WHERE status = 'failed'

UNION ALL
SELECT 'Total Returns', FORMAT(COUNT(*), 'N0')
FROM returns

UNION ALL
SELECT 'Total Refund Amount', FORMAT(SUM(refund_amount), 'N2')
FROM returns

UNION ALL
SELECT 'Average Refund Amount', FORMAT(AVG(refund_amount), 'N2')
FROM returns

UNION ALL
SELECT 'Total Restocked Items', FORMAT(COUNT(*), 'N0')
FROM returns
WHERE restocked = 1

UNION ALL
SELECT 'Total Non-Restocked Items', FORMAT(COUNT(*), 'N0')
FROM returns
WHERE restocked = 0

UNION ALL
SELECT 'Total Order Items', FORMAT(COUNT(order_item_id), 'N0')
FROM order_items

UNION ALL
SELECT 'Total Quantity Sold', FORMAT(SUM(quantity), 'N0')
FROM order_items

UNION ALL
SELECT 'Total Revenue', FORMAT(SUM((unit_price * quantity) - discount_amount), 'N2')
FROM order_items

UNION ALL
SELECT 'Total Discount Amount', FORMAT(SUM(discount_amount), 'N2')
FROM order_items

UNION ALL
SELECT 'Total Cost', FORMAT(SUM(P.unit_cost * OI.quantity), 'N2')
FROM order_items OI
INNER JOIN products P ON OI.product_id = P.product_id

UNION ALL
SELECT 'Total Profit', FORMAT(SUM((OI.unit_price * OI.quantity) - OI.discount_amount - (P.unit_cost * OI.quantity)), 'N2')
FROM order_items OI
INNER JOIN products P ON OI.product_id = P.product_id

UNION ALL
SELECT 'Total Orders', FORMAT(COUNT(*), 'N0')
FROM orders

UNION ALL
SELECT 'Average Order Value',
       FORMAT(SUM((OI.unit_price * OI.quantity) - OI.discount_amount) / COUNT(DISTINCT OI.order_id), 'N2')
FROM order_items OI

UNION ALL
SELECT 'Average Items per Order',
       FORMAT(CAST(COUNT(order_item_id) AS DECIMAL(18,2)) / COUNT(DISTINCT order_id), 'N2')
FROM order_items;