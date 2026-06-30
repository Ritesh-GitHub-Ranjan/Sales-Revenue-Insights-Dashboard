# 📊 Sales Revenue Insights Dashboard

> **Multi-page analytics dashboard** built on the Sample Superstore dataset (2015–2018). Covers executive KPIs, customer segmentation, product profitability, regional analysis, and operational performance — combining SQL, Python, and an interactive Power BI-style HTML dashboard.

---

## 🏆 Key Results (from real data analysis)

| Metric | Value |
|--------|-------|
| **Total Revenue** | $2,261,537 |
| **Total Profit** | $170,885 |
| **Profit Margin** | 7.6% |
| **Total Orders** | 4,922 |
| **Total Customers** | 793 |
| **Avg Order Value** | $459.48 |
| **YoY Growth (2017→2018)** | +20.3% |
| **Top Customer LTV** | $25,043 (Sean Miller) |

---

## 📁 Project Structure

```
Sales-Revenue-Insights-Dashboard/
│
├── data/
│   ├── raw/
│   │   └── superstore.csv            ← Original Superstore dataset (9,800 rows)
│   └── processed/
│       └── superstore_enriched.csv   ← Cleaned + feature-engineered dataset
│
├── sql/
│   ├── sales_analysis.sql            ← Executive KPIs, YoY, monthly trends
│   ├── customer_analysis.sql         ← RFM scoring, segment breakdown, LTV
│   └── product_analysis.sql          ← Sub-category profitability, discount impact
│
├── notebooks/
│   └── sales_analysis.ipynb          ← Full EDA, RFM, forecasting pipeline
│
├── dashboard/
│   ├── Sales_Dashboard.html          ← Interactive 5-page HTML dashboard (open in browser)
│   └── dax_measures.txt              ← All Power BI DAX measures + data model guide
│
├── outputs/
│   ├── executive_summary.csv         ← Top-line KPIs
│   ├── customer_summary.csv          ← Per-customer LTV, orders, segments
│   ├── product_summary.csv           ← Per-product revenue, profit, margins
│   ├── regional_summary.csv          ← City/state/region breakdown
│   └── monthly_summary.csv           ← Month-by-month revenue and profit
│
├── README.md
└── requirements.txt
```

---

## 📈 Dashboard Pages

The `dashboard/Sales_Dashboard.html` file is a fully interactive, browser-based dashboard with 5 pages — open it locally in any browser, no server required.

### Page 1 — Executive Overview
- 6 KPI cards: Revenue, Profit, Orders, Customers, AOV, YoY Growth
- 48-month revenue trend (2015–2018)
- Year-over-Year revenue + profit bar chart
- Revenue and margin breakdown by category

### Page 2 — Customer Analytics
- Revenue by segment (Consumer / Corporate / Home Office) — doughnut chart
- Top 10 customers by lifetime revenue with segment badges
- Customer detail table with revenue share

### Page 3 — Product Analytics
- Profit by sub-category (all 17 sub-categories, ranked)
- Discount band impact on total profit (5 bands: 0% to 31%+)

### Page 4 — Regional Analytics
- Revenue and profit bar charts for all 4 regions
- Revenue share progress bars with percentages

### Page 5 — Operational Analytics
- Seasonal demand by month (aggregated 2015–2018)
- Revenue by shipping mode — doughnut chart

---

## 🔍 Business Insights Discovered

### 1. Furniture Is a Profit Drain (Critical)
- Furniture generates $728K in revenue but runs at **–4.8% profit margin**
- **Tables sub-category** alone loses **$24,247** — the largest single drag on profitability
- Root cause: Average discount on Tables exceeds 30%, eroding all margin
- **Recommendation:** Cap Furniture discounts at 20%; review Tables pricing strategy

### 2. Orders with 31%+ Discounts Are Unprofitable
- Discount band analysis shows orders above 20% discount produce **negative aggregate profit**
  - 21–30% band: **–$21,350 total loss**
  - 31%+ band: **–$12,935 total loss**
- **Recommendation:** Enforce a 20% maximum discount ceiling — would recover ~$34K annually

### 3. Technology Is the Star Performer
- Technology generates the highest revenue ($827K) **and** highest profit ($112K)
- 13.6% margin with minimal discounting
- Phones sub-category alone contributes $49,329 in profit

### 4. Strong Q4 Seasonality — Operations Must Prepare
- September–December generates **43% of annual revenue** ($963K of $2.26M)
- November alone averages $350K across all years
- **Recommendation:** Scale inventory and staffing by early August each year

### 5. West and East Dominate Revenue — South Is Underpenetrated
- West (31.4%) + East (29.6%) = 61% of total revenue
- South contributes only 17.2% despite significant geography
- **Recommendation:** Targeted South region campaigns could unlock 5–8% revenue growth

### 6. YoY Recovery After 2016 Dip
- Revenue dipped in 2016 (–4.3%) but recovered strongly: +30.6% in 2017, +20.3% in 2018
- Suggests successful strategic or product mix changes in 2016–2017

---

## 🛠️ Tech Stack

| Layer | Tool |
|-------|------|
| Data Processing | Python (pandas, numpy) |
| Statistical Analysis | scikit-learn (LinearRegression, KMeans) |
| Visualization | matplotlib (notebook); Chart.js (dashboard) |
| SQL Analysis | PostgreSQL-compatible SQL (3 analytical files) |
| BI Dashboard | Interactive HTML + JavaScript (Power BI companion) |
| Power BI | DAX measures provided in `dashboard/dax_measures.txt` |

---

## 🚀 How to Run

### Python Analysis
```bash
# 1. Clone repo
git clone https://github.com/your-username/Sales-Revenue-Insights-Dashboard.git
cd Sales-Revenue-Insights-Dashboard

# 2. Install dependencies
pip install -r requirements.txt

# 3. Launch notebook
jupyter notebook notebooks/sales_analysis.ipynb
```

### Interactive Dashboard
```bash
# Simply open in any browser — no server required
open dashboard/Sales_Dashboard.html
```

### SQL Queries
Load `data/processed/superstore_enriched.csv` into any SQL engine (PostgreSQL, DuckDB, SQLite) as table `orders`, then run:
```bash
# Example with DuckDB (fastest)
pip install duckdb
python -c "import duckdb; duckdb.sql(\"CREATE TABLE orders AS SELECT * FROM read_csv_auto('data/processed/superstore_enriched.csv')\"); duckdb.sql(open('sql/sales_analysis.sql').read())"
```

### Power BI Desktop
1. Open Power BI Desktop → Get Data → CSV
2. Import all 5 files from `outputs/`
3. Create relationships per the guide in `dashboard/dax_measures.txt`
4. Copy DAX measures from `dax_measures.txt` into Power BI's Measure editor

---

## 📊 Dataset

**Source:** Sample Superstore Dataset (Kaggle / Tableau Public)  
**Size:** 9,800 rows × 18+ columns  
**Period:** January 2015 – December 2018  
**Geography:** United States (49 states)  
**Columns:** Order ID, Customer ID, Product ID, Category, Sub-Category, Sales, Profit, Quantity, Discount, Region, Segment, Ship Mode, Ship Date

---

## 📬 Contact

**Built by:** Ritesh  
**Stack:** Python · SQL · Power BI · Chart.js  
**Dataset:** Sample Superstore (2015–2018)
