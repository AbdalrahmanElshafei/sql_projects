
# E-Commerce SQL Exploratory Data Analysis

A structured **SQL Exploratory Data Analysis (EDA)** of an e-commerce database for an **online garden retailer**, built with **Microsoft SQL Server and T-SQL**.

The project is a sequence of **71 intended EDA questions**, each answered with a T-SQL query. The questions move from understanding the database itself, through data quality, to table-by-table exploration, and finish with a consolidated set of business metrics.

> **Python was used only for data ingestion.** A Jupyter Notebook loads the Parquet files into SQL Server. The actual EDA was performed in SQL Server using T-SQL.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Workflow](#workflow)
- [Database Schema](#database-schema)
- [Data Files and Volumes](#data-files-and-volumes)
- [Data Loading Notebook](#data-loading-notebook)
- [EDA Methodology](#eda-methodology)
- [EDA Questions](#eda-questions)
- [Business Formulas](#business-formulas)
- [Consolidated Business Metrics](#consolidated-business-metrics)
- [Analytical Notes](#analytical-notes)
- [Tools and Technologies](#tools-and-technologies)
- [Project Structure](#project-structure)
- [Skills Demonstrated](#skills-demonstrated)

---

## Project Overview

| Item | Details |
| --- | --- |
| Domain | E-commerce (online garden retailer) |
| Database | `Ecommerce_Orders` on Microsoft SQL Server |
| Language | T-SQL |
| Main file | `E-Commerce_EDA.sql` |
| Schema file | `ecommerce_orders.schema.sql` |
| Source data | Parquet files (7 tables) |
| Intended EDA questions | 71 |

**Numbering note:** the SQL file contains 72 query blocks but 71 intended questions, because one question number appears twice (number **26**: the last Products ranking question and the first Categories question). The original numbering is preserved in this README and is not renumbered.

---

## Workflow

```text
Parquet Files
      ↓
Pandas / Jupyter Notebook   (ingestion only)
      ↓
SQL Server
      ↓
T-SQL EDA
      ↓
Consolidated Business Metrics
```

---

## Database Schema

The schema is defined in `ecommerce_orders.schema.sql`. It covers table structures, columns, data types, primary keys, foreign keys, the category hierarchy, and Parquet data loading statements.

### Tables

| Table | Represents |
| --- | --- |
| `categories` | Product categories, including a parent/child hierarchy |
| `customers` | Registered customers |
| `products` | Products sold by the retailer |
| `orders` | Order-level records (one row per order) |
| `order_items` | Line items within orders (one row per product line) |
| `payments` | Payment records linked to orders |
| `returns` | Returns/refunds linked to order items |

### Relationships

| From | To | Meaning |
| --- | --- | --- |
| `categories.category_id` | `products.category_id` | Each product belongs to a category |
| `customers.customer_id` | `orders.customer_id` | Customers place orders |
| `orders.order_id` | `order_items.order_id` | An order contains line items |
| `products.product_id` | `order_items.product_id` | Line items reference products |
| `orders.order_id` | `payments.order_id` | Payments are attached to orders |
| `order_items.order_item_id` | `returns.order_item_id` | Returns are recorded against order items |
| `categories.parent_category_id` | `categories.category_id` | Self-reference forming the category hierarchy |

`orders` and `order_items` are separate tables because they represent different levels of the transaction: the order and its line items.

---

## Data Files and Volumes

The source data is stored in **Parquet** format in the `Data/` folder.

| Table | Parquet file | Rows |
| --- | --- | ---: |
| categories | `categories.parquet` | 24 |
| customers | `customers.parquet` | 12,000 |
| products | `products.parquet` | 2,000 |
| orders | `orders.parquet` | 90,000 |
| order_items | `order_items.parquet` | 215,000 |
| payments | `payments.parquet` | 95,000 |
| returns | `returns.parquet` | 12,000 |

---

## Data Loading Notebook

`Load_Data_to_SQL_Server.ipynb` is **not a Python analysis project**. It was used only to load the data into SQL Server, because there were problems importing the original Parquet files directly.

**Libraries:** Pandas, PyODBC, SQLAlchemy, and `quote_plus` from `urllib.parse`.

**What the notebook does:**

1. Creates a SQL Server connection.
2. Connects to the local SQL Server instance.
3. Uses the `Ecommerce_Orders` database.
4. Uses ODBC Driver 18 for SQL Server.
5. Reads the Parquet files with `pandas.read_parquet()`.
6. Loads all seven datasets into DataFrames.
7. Checks the shape of each DataFrame.
8. Inspects the column data types.
9. Stores the DataFrames in a dictionary.
10. Loads the tables into SQL Server with `DataFrame.to_sql()`, using `if_exists="append"`, `index=False`, and `chunksize=5000`.

---

## EDA Methodology

`E-Commerce_EDA.sql` is organized into ten stages:

| # | Stage |
| ---: | --- |
| 1 | Database Exploration |
| 2 | Data Quality Exploration |
| 3 | Customers EDA |
| 4 | Products EDA |
| 5 | Categories EDA |
| 6 | Payments EDA |
| 7 | Returns EDA |
| 8 | Order Items EDA |
| 9 | Orders EDA |
| 10 | Consolidated Business Metrics |

Within the table-level stages, questions are grouped into **Dimensions Exploration**, **Date Exploration**, **Measures Exploration**, **Magnitude Analysis**, and **Ranking Analysis**.

The project intentionally does **not** force every analysis type onto every table. Some tables have dimensions, some have dates, some have only measures, and ranking is used only where it adds value. Repetitive questions were avoided to keep the focus on structured EDA thinking rather than query volume.

---

## EDA Questions

### 1. Database Exploration

- Explore all tables in the database
- Explore all columns, including data types and ordinal positions
- Explore row counts for all tables

### 2. Data Quality Exploration

- Check NULL values across all tables using dynamic SQL
- Document the business meaning of intentional NULL values
- Investigate payment failure reasons and their relationship with payment status

Intentional NULLs are **meaningful business states**, not automatically errors requiring imputation:

| Column | NULL means |
| --- | --- |
| `categories.parent_category_id` | Top-level category with no parent |
| `customers.loyalty_tier` | Customer is not enrolled in the loyalty program |
| `products.discontinued_at` | Product is still on sale |
| `orders.coupon_code` | No coupon was used |
| `orders.shipped_at` | Order has not shipped yet or was cancelled |

### 3. Customers EDA

**Dimensions Exploration**

1. Explore Customer Countries
2. Explore Customer Cities
3. Explore Customer Loyalty Tiers
4. Explore Customer Marketing Preferences

**Date Exploration**

5. Explore Customer Signup Date Range (first signup date, last signup date, year range, month range)

**Measures Exploration**

6. Find the Total Number of Customers

**Magnitude Analysis**

7. Compare Customers Across Countries
8. Compare Customers Across Loyalty Tiers
9. Compare Customers by Marketing Preference

**Ranking Analysis**

10. Find the Top 10 Customers by Total Number of Orders
11. Find the Customers Who Made Only 1 Order
12. Find the Top 10 Customers Who Generated the Highest Revenue

### 4. Products EDA

**Dimensions Exploration**

13. Explore Product Categories
14. Explore Product Discontinued Status

**Date Exploration**

15. Analyze How Long Products Have Been Discontinued

**Measures Exploration**

16. Calculate Total Number of Products
17. Calculate Average Product Price
18. Calculate Average Product Cost
19. Calculate Average Product Profit Margin

**Magnitude Analysis**

20. Compare Products Across Categories
21. Compare Product Profit Margin Across Categories
22. Compare Average Product Cost Across Categories
23. Compare Total Sales Across Products

**Ranking Analysis**

24. Find the Top 10 Products by Total Revenue
25. Find the Top 10 Products by Total Quantity Sold
26. Find the Top 10 Products by Total Profit

### 5. Categories EDA

**Dimensions Exploration**

26. Explore Category Hierarchy *(number 26 is used twice in the source file)*

**Measures Exploration**

27. Calculate Total Number of Top-Level Categories
28. Calculate Total Number of All Categories

**Magnitude Analysis**

29. Compare Top-Level Categories by Number of Subcategories
30. Compare Total Revenue Across Categories
31. Compare Total Profit Across Categories
32. Compare Total Cost Across Categories
33. Compare Total Quantity Sold Across Categories

**Ranking Analysis**

34. Find the Top 10 Categories by Total Revenue

### 6. Payments EDA

**Dimensions Exploration**

35. Explore Payment Methods
36. Explore Payment Status
37. Explore Payment Failure Reasons

**Measures Exploration**

38. Calculate Total Number of Payments
39. Calculate Total Payment Amount
40. Calculate Total Captured Payment Amount
41. Calculate Total Failed Payment Amount

**Magnitude Analysis**

42. Compare Total Payments Across Payment Methods
43. Compare Total Payment Amount Across Payment Methods
44. Compare Total Failed Payment Amount Across Payment Methods
45. Compare Total Payment Amount Across Payment Statuses
46. Compare Payment Failure Reasons

### 7. Returns EDA

**Dimensions Exploration**

47. Explore Return Reasons

**Measures Exploration**

48. Calculate Total Number of Returns
49. Calculate Total Refund Amount
50. Calculate Average Refund Amount
51. Calculate Total Restocked Items
52. Calculate Total Non-Restocked Items

**Magnitude Analysis**

53. Compare Total Refund Amount by Return Reason
54. Compare Total Returns by Return Reason
55. Compare Total Refund Amount by Restock Status
56. Compare Total Returns by Restock Status

Restock flag: `restocked = 1` is Restocked, `restocked = 0` is Non-Restocked.

### 8. Order Items EDA

`order_items` is treated separately because it represents the line-item level of transactions. It is the source for revenue, cost, and profit.

**Measures Exploration**

57. Calculate Total Number of Order Items
58. Calculate Total Quantity Sold
59. Calculate Total Revenue from Order Items
60. Calculate Total Discount Amount
61. Calculate Total Cost from Order Items
62. Calculate Total Profit from Order Items

### 9. Orders EDA

**Dimensions Exploration**

63. Explore Order Status
64. Explore Order Channels

**Date Exploration**

65. Explore Order Date Range
66. Explore Order Years

**Measures Exploration**

67. Calculate Total Number of Orders
68. Calculate Average Order Value
69. Calculate Average Items per Order

**Magnitude Analysis**

70. Compare Total Orders by Order Status
71. Compare Total Orders by Order Channel

---

## Business Formulas

Revenue, cost, and profit are calculated from the `order_items` table:

```text
Revenue = (unit_price × quantity) - discount_amount
Cost    = unit_cost × quantity
Profit  = Revenue - Cost
```

- **Revenue** is the line value after discounts.
- **Cost** is the unit cost multiplied by the quantity sold.
- **Profit** is revenue minus cost.

---

## Consolidated Business Metrics

The final query in `E-Commerce_EDA.sql` uses `UNION ALL` to return key metrics in **one consolidated result set**. It provides a compact KPI summary after the detailed EDA.

| Area | Metrics |
| --- | --- |
| Categories | Total Top-Level Categories, Total Categories |
| Payments | Total Payments, Total Payment Amount, Total Captured Payment Amount, Total Failed Payment Amount |
| Returns | Total Returns, Total Refund Amount, Average Refund Amount, Total Restocked Items, Total Non-Restocked Items |
| Order Items | Total Order Items, Total Quantity Sold, Total Revenue, Total Discount Amount, Total Cost, Total Profit |
| Orders | Total Orders, Average Order Value, Average Items per Order |

---

## Analytical Notes

- **Payments vs. revenue:** payments are analyzed separately from revenue. Payment amounts and order-item revenue are different business concepts and are not assumed to match.
- **Failed payment amount** is the value of failed payment attempts. It is not treated as confirmed business loss.
- **Non-restocked returns:** the refund amount of non-restocked items is not automatically treated as confirmed accounting loss.
- **Intentional NULLs** are preserved as business states rather than imputed.
- **Focused scope:** ranking and date analyses appear only where they add value.

---

## Tools and Technologies

- Microsoft SQL Server
- T-SQL
- Python
- Jupyter Notebook
- Pandas
- SQLAlchemy
- PyODBC
- Parquet

---

## Project Structure

```text
E-Commerce-SQL-EDA/
│
├── README.md
├── ecommerce_orders.schema.sql
├── E-Commerce_EDA.sql
├── Load_Data_to_SQL_Server.ipynb
│
└── Data/
    ├── categories.parquet
    ├── customers.parquet
    ├── products.parquet
    ├── orders.parquet
    ├── order_items.parquet
    ├── payments.parquet
    └── returns.parquet
```

---

## Skills Demonstrated

| Area | Skills |
| --- | --- |
| Database exploration | Relational database exploration, database metadata exploration, working with multiple related tables |
| Data quality | NULL and data-quality analysis, interpreting intentional NULLs |
| EDA structure | Dimension exploration, date exploration, measure calculation, magnitude comparisons, structured SQL EDA |
| T-SQL techniques | Aggregation, `GROUP BY`, filtering, `CASE` expressions, `ISNULL`, JOINs, self-joins, dynamic SQL, `UNION ALL` |
| Analysis | Ranking and Top-N analysis, revenue, cost, and profit calculations, payment analysis, return/refund analysis, KPI construction |
| Data handling | Working with Parquet data, loading data into SQL Server with Python |
