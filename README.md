# 🚚 Supply Chain & Inventory Performance Intelligence Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white)

An end-to-end enterprise supply chain analytics project built on the **DataCo Global Supply Chain dataset**. This solution integrates **SQL Star Schema data modeling**, **Python-driven ABC/XYZ inventory segmentation**, and an interactive **Power BI Executive Dashboard** to evaluate lead-time variance, shipping delays, and stockout risk policies.

---

## 📸 Executive Dashboard Overview

![Supply Chain Dashboard](docs/dashboard_preview.png)
![Dashboard Preview](docs/dashboard_preview.png)
[Download Full PDF Dashboard](docs/Supply_Chain_Dashboard.pdf)

---

## 💡 Key Business Metrics & Key Takeaways

* **Total Revenue:** **$36.78M** gross sales tracked across global logistics channels.
* **Late Delivery Rate:** **54.83%** operational delays identified across carriers (First Class showing highest delays at **95.32%**).
* **OTIF Rate (%):** **17.84%** On-Time In-Full fulfillment efficiency.
* **Stockout Risk Status:** **Inventory Stable** via automated dynamic buffer tracking on **AZ & BZ** volatile SKUs.

---

## 🏗️ Technical Architecture & Workflow

### 1. SQL Data Modeling (PostgreSQL)
* **Staging & Cleaning:** Normalized raw relational data (`stg_supply_chain1`).
* **Star Schema Architecture:**
  * **Fact Table:** `fact_orders` (Grain: Individual order line item level).
  * **Dimension Tables:** `dim_customers`, `dim_products`, `dim_location`.
* **Analytical Queries:** Calculated 30-day rolling demand trends, customer lifetime value rankings, and lead-time variance per shipping mode.

### 2. Python EDA & Advanced Inventory Segmentation
* **Exploratory Data Analysis:** Evaluated correlation between delivery delays and order profitability.
* **ABC Analysis (Revenue Pareto):**
  * **Class A:** Top 80% cumulative revenue.
  * **Class B:** Next 15% revenue.
  * **Class C:** Bottom 5% long-tail revenue.
* **XYZ Analysis (Demand Volatility):** Calculated **Coefficient of Variation ($CV = \frac{\sigma}{\mu}$)** across monthly order quantities:
  * **X Class ($CV \le 0.5$):** Uniform, stable demand.
  * **Y Class ($0.5 < CV \le 1.0$):** Variable/seasonal demand.
  * **Z Class ($CV > 1.0$):** Highly unpredictable demand.
* **Automated Inventory Policy Mapping:** Assigned 9 distinct safety-stock strategies (`AX` to `CZ`).

### 3. Power BI Executive Dashboard
* Integrated DAX measures for real-time KPI evaluations.
* Designed a 9-box **ABC / XYZ Matrix Visual** mapping unique SKU counts against revenue performance.
* Constructed a **Critical SKU Action Plan Table** with automated safety stock policy recommendations.

---

## 💻 How to Run This Project

### Prerequisites
* **PostgreSQL** or any SQL database engine.
* **Python 3.9+** with libraries listed in `requirements.txt`.
* **Power BI Desktop**.

### Step 1: SQL Database Setup
Execute the scripts in `sql/supply_chain_sql_queries.sql` to stage raw data and build the Star Schema model.

### Step 2: Run Python Inventory Segmentation Script
```bash
pip install -r requirements.txt
python python/Supplychain_pythonScript.py
