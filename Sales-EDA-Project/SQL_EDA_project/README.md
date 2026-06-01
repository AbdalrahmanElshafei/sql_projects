# SQL Exploratory Data Analysis (EDA) Project

## 📌 Project Overview
This project is a SQL-based Exploratory Data Analysis (EDA) on a retail sales dataset.  
It focuses on understanding business performance through answering key analytical questions about sales, customers, products, and time trends.

---

## 🗄️ Dataset
The dataset consists of 3 main tables:
- fact_sales (transactions)
- dim_customers (customer data)
- dim_products (product data)

---

## 🧰 Tools Used
- SQL Server (T-SQL)
- SSMS
- GitHub

---

# 🔍 Database Exploration

### Q1: What tables exist in the database?
SELECT * FROM INFORMATION_SCHEMA.TABLES;
----
📊 Result:

![01](Screenshots/01_database_tables.png.png)

---

### Q2: What columns are available in the database?

📊 Result:

![02](Screenshots/02_database_columns.png)

---

# 🌍 Dimensions Exploration

### Q3: From which countries do customers come?

📊 Result:

![03](Screenshots/03_distinct_countries.png)

---

### Q4: What product categories exist in the dataset?

📊 Result:

![04](Screenshots/04_distinct_categories.png)

---

### Q5: What product subcategories exist?

📊 Result:

![05](Screenshots/05_distinct_subcategories.png)

---

# 📅 Date Exploration

### Q6: What is the first and last order date?

📊 Result:

![07](Screenshots/07_first_last_order_date.png)

---

### Q7: How many years of sales data are available?

📊 Result:

![08](Screenshots/08_sales_year_range.png)

---

### Q8: How many months of sales data are available?

📊 Result:

![09](Screenshots/09_sales_month_range.png)

---

# 👥 Customer Analysis

### Q9: What is the age distribution of customers?

📊 Result:

![10](Screenshots/10_customer_age_analysis.png)

---

### Q10: How many total customers exist?

📊 Result:

![16](Screenshots/16_total_customers.png)

---

### Q11: Which countries have the most customers?

📊 Result:

![18](Screenshots/18_customers_by_country.png)

---

### Q12: What is the gender distribution of customers?

📊 Result:

![19](Screenshots/19_customers_by_gender.png)

---

# 📊 Business Performance

### Q13: What is the total sales amount?

📊 Result:

![11](Screenshots/11_total_sales.png)

---

### Q14: How many total products were sold?

📊 Result:

![12](Screenshots/12_total_quantity_sold.png)

---

### Q15: What is the average selling price?

📊 Result:

![13](Screenshots/13_average_price.png)

---

### Q16: How many total orders were placed?

📊 Result:

![14](Screenshots/14_total_orders.png)

---

### Q17: How many products exist in the dataset?

📊 Result:

![15](Screenshots/15_total_products.png)

---

### Q18: What is the KPI summary of the business?

📊 Result:

![17](Screenshots/17_business_kpi_report.png)

---

# 📈 Revenue Analysis

### Q19: Which category generates the highest revenue?

📊 Result:

![22](Screenshots/22_revenue_by_category.png)

---

### Q20: Which customers generate the highest revenue?

📊 Result:

![23](Screenshots/23_revenue_by_customer.png)

---

### Q21: Which countries have the highest quantity sold?

📊 Result:

![24](Screenshots/24_quantity_by_country.png)

---

# 🏆 Ranking Analysis

### Q22: What are the top 5 best-selling products?

📊 Result:

![25](Screenshots/25_top_5_products.png)

---

### Q23: What are the worst 5 performing products?

📊 Result:

![26](Screenshots/26_worst_5_products.png)

---

### Q24: Who are the top 10 customers by revenue?

📊 Result:

![28](Screenshots/28_top_10_customers.png)

---

### Q25: Which customers placed only one order?

📊 Result:

![29](Screenshots/29_customers_single_order.png)

---

# 💡 Key Insights
- Revenue is highly concentrated in a small number of products.
- A small percentage of customers generate most of the revenue.
- Certain countries dominate sales performance.
- Strong differences exist between top and low-performing products.

---

# 🚀 Conclusion
This project demonstrates SQL analytical skills in exploring datasets, answering business questions, and extracting actionable insights for decision-making.
