-- ============================================================
-- Sales Revenue Insights Dashboard
-- File: customer_analysis.sql
-- Purpose: Customer segmentation, RFM scoring, lifetime value
-- Dataset: Sample Superstore (2015–2018)
-- ============================================================

-- ----------------------------------------------------------------
-- 1. CUSTOMER SEGMENT REVENUE BREAKDOWN
-- ----------------------------------------------------------------
SELECT
    "Segment",
    COUNT(DISTINCT "Customer ID")                         AS customers,
    COUNT(DISTINCT "Order ID")                            AS orders,
    ROUND(SUM("Sales"), 2)                                AS revenue,
    ROUND(SUM("Profit"), 2)                               AS profit,
    ROUND(SUM("Sales") / COUNT(DISTINCT "Customer ID"), 2) AS revenue_per_customer,
    ROUND(SUM("Sales") / COUNT(DISTINCT "Order ID"), 2)   AS avg_order_value,
    ROUND(COUNT(DISTINCT "Order ID")::NUMERIC / COUNT(DISTINCT "Customer ID"), 1) AS orders_per_customer
FROM orders
GROUP BY "Segment"
ORDER BY revenue DESC;
-- Corporate customers: higher avg order value, fewer total orders — premium buyers
-- Home Office: smallest segment but high per-customer value


-- ----------------------------------------------------------------
-- 2. TOP 20 CUSTOMERS BY REVENUE
-- ----------------------------------------------------------------
SELECT
    "Customer ID",
    "Customer Name",
    "Segment",
    "Region",
    COUNT(DISTINCT "Order ID")                         AS total_orders,
    ROUND(SUM("Sales"), 2)                             AS lifetime_revenue,
    ROUND(SUM("Profit"), 2)                            AS lifetime_profit,
    ROUND(SUM("Profit") / SUM("Sales") * 100, 2)      AS margin_pct,
    MIN(TO_DATE("Order Date", 'DD/MM/YYYY'))           AS first_order,
    MAX(TO_DATE("Order Date", 'DD/MM/YYYY'))           AS last_order
FROM orders
GROUP BY "Customer ID", "Customer Name", "Segment", "Region"
ORDER BY lifetime_revenue DESC
LIMIT 20;


-- ----------------------------------------------------------------
-- 3. RFM SCORING (Recency, Frequency, Monetary)
-- ----------------------------------------------------------------
WITH reference_date AS (
    SELECT MAX(TO_DATE("Order Date", 'DD/MM/YYYY')) AS max_date
    FROM orders
),
rfm_base AS (
    SELECT
        "Customer ID",
        "Customer Name",
        "Segment",
        MAX(TO_DATE("Order Date", 'DD/MM/YYYY'))                      AS last_order_date,
        (SELECT max_date FROM reference_date)
            - MAX(TO_DATE("Order Date", 'DD/MM/YYYY'))                AS recency_days,
        COUNT(DISTINCT "Order ID")                                    AS frequency,
        ROUND(SUM("Sales"), 2)                                        AS monetary
    FROM orders
    GROUP BY "Customer ID", "Customer Name", "Segment"
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,  -- lower recency = better
        NTILE(5) OVER (ORDER BY frequency DESC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)       AS m_score
    FROM rfm_base
)
SELECT
    "Customer ID",
    "Customer Name",
    "Segment",
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)  AS rfm_total_score,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Potential Loyalist'
        WHEN r_score >= 4 AND (f_score + m_score) <= 4 THEN 'New Customer'
        WHEN r_score <= 2 AND (f_score + m_score) >= 7  THEN 'At-Risk Customer'
        WHEN (r_score + f_score + m_score) <= 5  THEN 'Lost Customer'
        ELSE 'Needs Attention'
    END AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total_score DESC;


-- ----------------------------------------------------------------
-- 4. REPEAT vs SINGLE-ORDER CUSTOMER ANALYSIS
-- ----------------------------------------------------------------
WITH order_counts AS (
    SELECT
        "Customer ID",
        "Customer Name",
        "Segment",
        COUNT(DISTINCT "Order ID")  AS order_count,
        ROUND(SUM("Sales"), 2)      AS total_spend
    FROM orders
    GROUP BY "Customer ID", "Customer Name", "Segment"
)
SELECT
    CASE WHEN order_count = 1 THEN 'One-Time Buyer'
         WHEN order_count BETWEEN 2 AND 4 THEN 'Occasional Buyer'
         ELSE 'Repeat Buyer (5+)'
    END AS buyer_type,
    COUNT(*)                              AS customer_count,
    ROUND(SUM(total_spend), 2)            AS total_revenue,
    ROUND(AVG(total_spend), 2)            AS avg_spend,
    ROUND(AVG(order_count), 1)            AS avg_orders
FROM order_counts
GROUP BY 1
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------
-- 5. CUSTOMER SUMMARY TABLE (for Power BI import)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW customer_summary AS
SELECT
    "Customer ID",
    "Customer Name",
    "Segment",
    "Region",
    COUNT(DISTINCT "Order ID")                              AS total_orders,
    ROUND(SUM("Quantity"), 0)                               AS total_units,
    ROUND(SUM("Sales"), 2)                                  AS lifetime_value,
    ROUND(SUM("Profit"), 2)                                 AS lifetime_profit,
    MIN(TO_DATE("Order Date", 'DD/MM/YYYY'))                AS first_purchase,
    MAX(TO_DATE("Order Date", 'DD/MM/YYYY'))                AS last_purchase,
    MAX(TO_DATE("Order Date", 'DD/MM/YYYY'))
        - MIN(TO_DATE("Order Date", 'DD/MM/YYYY'))          AS customer_tenure_days
FROM orders
GROUP BY "Customer ID", "Customer Name", "Segment", "Region";
