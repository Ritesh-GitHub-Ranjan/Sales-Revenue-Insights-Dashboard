-- ============================================================
-- Sales Revenue Insights Dashboard
-- File: product_analysis.sql
-- Purpose: Product profitability, discount impact, sub-category analysis
-- Dataset: Sample Superstore (2015–2018)
-- ============================================================

-- ----------------------------------------------------------------
-- 1. CATEGORY-LEVEL PROFITABILITY
-- ----------------------------------------------------------------
SELECT
    "Category",
    COUNT(DISTINCT "Product ID")                          AS unique_products,
    COUNT(DISTINCT "Order ID")                            AS orders,
    ROUND(SUM("Quantity"), 0)                             AS units_sold,
    ROUND(SUM("Sales"), 2)                                AS revenue,
    ROUND(SUM("Profit"), 2)                               AS profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)         AS profit_margin_pct,
    ROUND(AVG("Discount") * 100, 1)                       AS avg_discount_pct
FROM orders
GROUP BY "Category"
ORDER BY profit DESC;
-- Technology leads in profit despite fewer orders; Furniture loses money from heavy discounting


-- ----------------------------------------------------------------
-- 2. SUB-CATEGORY DEEP DIVE
-- ----------------------------------------------------------------
SELECT
    "Category",
    "Sub-Category",
    COUNT(DISTINCT "Product ID")                          AS products,
    COUNT(DISTINCT "Order ID")                            AS orders,
    ROUND(SUM("Sales"), 2)                                AS revenue,
    ROUND(SUM("Profit"), 2)                               AS profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)         AS margin_pct,
    ROUND(AVG("Discount") * 100, 1)                       AS avg_discount_pct,
    CASE
        WHEN SUM("Profit") / SUM("Sales") * 100 < 0   THEN '🔴 Losing Money'
        WHEN SUM("Profit") / SUM("Sales") * 100 < 5   THEN '🟡 Low Margin'
        WHEN SUM("Profit") / SUM("Sales") * 100 < 15  THEN '🟢 Healthy'
        ELSE '⭐ High Margin'
    END AS margin_flag
FROM orders
GROUP BY "Category", "Sub-Category"
ORDER BY "Category", profit DESC;


-- ----------------------------------------------------------------
-- 3. DISCOUNT IMPACT ANALYSIS
-- ----------------------------------------------------------------
WITH discount_buckets AS (
    SELECT
        CASE
            WHEN "Discount" = 0         THEN '0% — No Discount'
            WHEN "Discount" <= 0.10     THEN '1–10%'
            WHEN "Discount" <= 0.20     THEN '11–20%'
            WHEN "Discount" <= 0.30     THEN '21–30%'
            ELSE '31%+'
        END AS discount_band,
        "Sales",
        "Profit",
        "Discount"
    FROM orders
)
SELECT
    discount_band,
    COUNT(*)                                         AS line_items,
    ROUND(SUM("Sales"), 2)                           AS revenue,
    ROUND(SUM("Profit"), 2)                          AS profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)    AS margin_pct
FROM discount_buckets
GROUP BY discount_band
ORDER BY discount_band;
-- Insight: Orders with 31%+ discount average negative profit margins — key finding for pricing team


-- ----------------------------------------------------------------
-- 4. TOP 15 MOST PROFITABLE PRODUCTS
-- ----------------------------------------------------------------
SELECT
    "Product ID",
    "Product Name",
    "Category",
    "Sub-Category",
    COUNT(DISTINCT "Order ID")                         AS orders,
    ROUND(SUM("Sales"), 2)                             AS revenue,
    ROUND(SUM("Profit"), 2)                            AS profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)      AS margin_pct
FROM orders
GROUP BY "Product ID", "Product Name", "Category", "Sub-Category"
ORDER BY profit DESC
LIMIT 15;


-- ----------------------------------------------------------------
-- 5. TOP 10 PROFIT-DRAINING PRODUCTS
-- ----------------------------------------------------------------
SELECT
    "Product ID",
    "Product Name",
    "Category",
    "Sub-Category",
    COUNT(DISTINCT "Order ID")                         AS orders,
    ROUND(SUM("Sales"), 2)                             AS revenue,
    ROUND(SUM("Profit"), 2)                            AS profit,
    ROUND(AVG("Discount") * 100, 1)                    AS avg_discount_pct
FROM orders
GROUP BY "Product ID", "Product Name", "Category", "Sub-Category"
HAVING SUM("Profit") < 0
ORDER BY profit ASC
LIMIT 10;
-- Action: Review discount policy for Tables — losing money despite high volume


-- ----------------------------------------------------------------
-- 6. PRODUCT SUMMARY VIEW (for Power BI import)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW product_summary AS
SELECT
    "Product ID",
    "Product Name",
    "Category",
    "Sub-Category",
    COUNT(DISTINCT "Order ID")                              AS total_orders,
    ROUND(SUM("Quantity"), 0)                               AS total_units_sold,
    ROUND(SUM("Sales"), 2)                                  AS total_revenue,
    ROUND(SUM("Profit"), 2)                                 AS total_profit,
    ROUND(SUM("Profit") / NULLIF(SUM("Sales"), 0) * 100, 2) AS profit_margin_pct,
    ROUND(AVG("Discount") * 100, 2)                         AS avg_discount_pct
FROM orders
GROUP BY "Product ID", "Product Name", "Category", "Sub-Category";
