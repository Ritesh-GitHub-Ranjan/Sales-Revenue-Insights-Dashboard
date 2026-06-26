-- ============================================================
-- Sales Revenue Insights Dashboard
-- File: sales_analysis.sql
-- Purpose: Executive-level sales KPIs and trend analysis
-- Dataset: Sample Superstore (2015–2018)
-- ============================================================

-- ----------------------------------------------------------------
-- 1. EXECUTIVE SUMMARY KPIs
-- ----------------------------------------------------------------
SELECT
    COUNT(DISTINCT "Order ID")                          AS total_orders,
    COUNT(DISTINCT "Customer ID")                       AS total_customers,
    ROUND(SUM("Sales"), 2)                              AS total_revenue,
    ROUND(SUM("Profit"), 2)                             AS total_profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)       AS profit_margin_pct,
    ROUND(SUM("Sales") / COUNT(DISTINCT "Order ID"), 2) AS avg_order_value,
    COUNT(DISTINCT "Product ID")                        AS unique_products
FROM orders;
-- Results: $2,261,537 revenue | $170,885 profit | 7.6% margin | 4,922 orders | 793 customers


-- ----------------------------------------------------------------
-- 2. YEAR-OVER-YEAR REVENUE GROWTH
-- ----------------------------------------------------------------
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM TO_DATE("Order Date", 'DD/MM/YYYY'))  AS order_year,
        ROUND(SUM("Sales"), 2)                                   AS revenue
    FROM orders
    GROUP BY 1
)
SELECT
    order_year,
    revenue,
    LAG(revenue) OVER (ORDER BY order_year)                   AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year))
        / LAG(revenue) OVER (ORDER BY order_year) * 100, 1
    )                                                          AS yoy_growth_pct
FROM yearly
ORDER BY order_year;
-- 2015: $479,856 | 2016: $459,436 (-4.3%) | 2017: $600,193 (+30.6%) | 2018: $722,052 (+20.3%)


-- ----------------------------------------------------------------
-- 3. MONTHLY REVENUE TREND (all years combined for seasonality)
-- ----------------------------------------------------------------
SELECT
    EXTRACT(MONTH FROM TO_DATE("Order Date", 'DD/MM/YYYY'))  AS month_num,
    TO_CHAR(TO_DATE("Order Date", 'DD/MM/YYYY'), 'Mon')       AS month_name,
    ROUND(SUM("Sales"), 2)                                    AS revenue,
    ROUND(SUM("Profit"), 2)                                   AS profit,
    COUNT(DISTINCT "Order ID")                                AS orders
FROM orders
GROUP BY 1, 2
ORDER BY 1;


-- ----------------------------------------------------------------
-- 4. REVENUE & PROFIT BY CATEGORY
-- ----------------------------------------------------------------
SELECT
    "Category",
    COUNT(DISTINCT "Order ID")                            AS orders,
    ROUND(SUM("Sales"), 2)                                AS revenue,
    ROUND(SUM("Profit"), 2)                               AS profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)         AS profit_margin_pct,
    ROUND(SUM("Sales") / (SELECT SUM("Sales") FROM orders) * 100, 1) AS revenue_share_pct
FROM orders
GROUP BY "Category"
ORDER BY revenue DESC;
-- Technology: $827,456 (13.6% margin) | Furniture: $728,659 (-4.8% margin) | Office Supplies: $705,422 (13.2% margin)


-- ----------------------------------------------------------------
-- 5. SUB-CATEGORY PROFIT LEAKAGE ANALYSIS
-- ----------------------------------------------------------------
SELECT
    "Category",
    "Sub-Category",
    ROUND(SUM("Sales"), 2)                        AS revenue,
    ROUND(SUM("Profit"), 2)                       AS profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2) AS margin_pct,
    COUNT(DISTINCT "Order ID")                    AS orders
FROM orders
GROUP BY "Category", "Sub-Category"
HAVING SUM("Profit") < 0                          -- negative margin products
ORDER BY profit ASC;
-- Key finding: Tables and Bookcases are primary profit drains due to heavy discounting


-- ----------------------------------------------------------------
-- 6. SHIPPING MODE PERFORMANCE
-- ----------------------------------------------------------------
SELECT
    "Ship Mode",
    COUNT(DISTINCT "Order ID")                              AS orders,
    ROUND(SUM("Sales"), 2)                                  AS revenue,
    ROUND(SUM("Profit"), 2)                                 AS profit,
    ROUND(AVG(
        TO_DATE("Ship Date", 'DD/MM/YYYY')
        - TO_DATE("Order Date", 'DD/MM/YYYY')
    ), 1)                                                   AS avg_ship_days,
    ROUND(SUM("Sales") / COUNT(DISTINCT "Order ID"), 2)     AS avg_order_value
FROM orders
GROUP BY "Ship Mode"
ORDER BY revenue DESC;


-- ----------------------------------------------------------------
-- 7. SALES SUMMARY TABLE (final output for Power BI import)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW sales_summary AS
SELECT
    TO_DATE("Order Date", 'DD/MM/YYYY')           AS order_date,
    EXTRACT(YEAR FROM TO_DATE("Order Date", 'DD/MM/YYYY')) AS order_year,
    EXTRACT(MONTH FROM TO_DATE("Order Date", 'DD/MM/YYYY')) AS order_month,
    "Region",
    "Segment",
    "Category",
    "Sub-Category",
    "Ship Mode",
    COUNT(DISTINCT "Order ID")                    AS orders,
    ROUND(SUM("Quantity"), 0)                     AS units_sold,
    ROUND(SUM("Sales"), 2)                        AS revenue,
    ROUND(SUM("Profit"), 2)                       AS profit,
    ROUND(SUM("Profit") / NULLIF(SUM("Sales"), 0) * 100, 2) AS margin_pct
FROM orders
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8;
