# 🛒 E-Commerce Profitability Analysis

### BrightCart — End-to-End Data Analytics Project

An end-to-end data analytics project that analyzes **e-commerce profitability, sales channel performance, customer returns, and marketing effectiveness** using MySQL, Python, and Power BI.

---

## 📌 Project Overview

BrightCart is a fictional direct-to-consumer e-commerce company selling products across multiple categories and sales channels.

Although the company generates healthy revenue, management is concerned about shrinking profit margins.

The key question is:

> **Where is BrightCart actually making money, and where is it losing money after accounting for all major costs?**

This project combines order-level transaction data, product cost information, and marketing spend to evaluate profitability across products, categories, sales channels, and marketing platforms.

---

# 🎯 Business Problem

BrightCart generated more than $1M in gross revenue over the past two years, but its net margins have been shrinking.

Revenue alone does not provide a complete picture of business performance because profitability is affected by:

- Product costs
- Shipping costs
- Returns and refunds
- Discounts
- Platform fees
- Marketing spend

Management therefore needs to understand:

1. Which product categories are truly profitable?
2. Which sales channels generate the strongest profit?
3. Which categories or channels are generating losses?
4. How much are returns affecting profitability?
5. Which marketing platforms provide the best ROAS?
6. Where should marketing spending be reduced if the company needs to cut its budget by 20%?

---

# 🎯 Project Objectives

The analysis aims to:

- Measure overall revenue and profitability.
- Compare profitability across product categories.
- Evaluate profitability across sales channels.
- Identify loss-making orders and channels.
- Diagnose cost and refund factors associated with profitability.
- Evaluate marketing performance using ROAS.
- Identify low-performing marketing investments.
- Recommend actions to improve overall profitability.

---

# 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **MySQL** | Data storage, SQL querying, aggregation, and business analysis |
| **Python** | Deeper exploratory and diagnostic analysis |
| **Pandas** | Data manipulation and analysis |
| **NumPy** | Numerical analysis |
| **Matplotlib** | Exploratory visualization |
| **Power BI** | Interactive dashboard and business intelligence |
| **DAX** | KPI and profitability calculations |
| **Git & GitHub** | Version control and portfolio documentation |

---

# 🔄 Analytics Workflow

```text
Datasets
   │
   ▼
 MySQL
   │
   ├── SQL Analysis
   │      ├── Descriptive Analysis
   │      ├── Diagnostic Analysis
   │      └── Prescriptive Analysis
   │
   ▼
Python / Pandas
   │
   └── Deeper Diagnostic Analysis
          └── Correlation Analysis
          
   ▼
Power BI
   │
   ├── Data Modeling
   ├── DAX Measures
   ├── KPI Analysis
   └── Dashboard Visualization
   
   ▼
Business Insights
   │
   ▼
Recommendations