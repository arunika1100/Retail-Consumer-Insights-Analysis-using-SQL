# Retail-Consumer-Insights-Analysis-using-SQL
Data analysis project focused on retail sales patterns, consumer behaviour, and product performance using PostgreSQL.

## 🚀 Project Overview
This project focuses on analyzing retail sales patterns, consumer behavior, and product performance using PostgreSQL. The goal is to derive actionable business insights from raw sales data.

## 📊 Dataset Information
Dataset Size: 1000+ records
Columns: Customer_ID, Product_Category, Gender, Sales, etc.

## 🔍 Key SQL Concepts Used
- GROUP BY
- CASE WHEN
- Aggregate Functions
- Subqueries
- CTEs
- Window Functions (if used)

## 🛠 Tools Used
Database: PostgreSQL
Tool: pgAdmin 4
Language: SQL

## 🛠️ How to Run
1. Create database in PostgreSQL.
2. Import sales.csv.
3. Run analysis_queries.sql.

## 📈 Business Problems & Solutions

 **Business Problem: Product Demand**
 Solution: Identified high-selling products to optimize stock levels and reduce inventory costs. 
 **Business Problem: Order Cancellations**  
 Solution: Analyzed frequent cancellation patterns to improve quality control and customer retention.  
 **Business Problem: Peak Sales Time**
 Solution: Extracted time-of-day trends to optimize staffing, promotions, and server loads.
 **Business Problem: Customer Value**
 Solution: Identified high-spending customers for loyalty programs and personalized marketing. 
 **Business Problem: Gender-based Preferences**
 Solution: Uncovered gender-specific product preferences for targeted ad campaigns. 

## 📈 Some Business Insights

### 1. Inventory & Supply Chain Optimization
**Insight:** By identifying the "top 5 most selling products by quantity," the business can optimize its stock levels.  
**Business Impact:** This prevents stockouts of popular items while reducing storage costs for low-demand products, ensuring capital is not tied up in slow-moving inventory.

### 2. Quality Control & Customer Retention
**Insight:** By pinpointing "products that are most frequently cancelled," you provide data on potential quality issues or customer dissatisfaction.  
**Business Impact:** Addressing these specific product pain points directly improves customer trust and reduces revenue loss from returned or cancelled orders.

### 3. Operational Efficiency & Staffing
**Insight:** By segmenting purchase times into buckets like 'Morning', 'Afternoon', and 'Evening', you have identified peak traffic times.  
**Business Impact:** The business can now optimize store staffing schedules and server bandwidth during high-traffic hours to ensure smooth operations.

### 4. Targeted Marketing Strategy
**Insight:** Your analysis of gender-based preferences for specific categories (e.g., Accessories, Furniture, Books) provides a clear demographic breakdown.  
**Business Impact:** This allows the marketing team to design personalized ad campaigns, which are significantly more effective at converting customers than generic, one-size-fits-all advertisements.
