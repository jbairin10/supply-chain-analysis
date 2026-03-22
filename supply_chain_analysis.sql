-- ================================================
-- SUPPLY CHAIN ANALYSIS
-- ================================================
-- Goal: Identify inventory risk, supplier performance,
-- and revenue drivers across 100 SKUs
-- Dataset: supply_chain_data
-- ================================================


-- ================================================
-- Q1: Which products are at stockout risk?
-- ================================================
-- Stock levels alone don't tell the full story.
-- A product with 100 units sounds fine but if it 
-- sells 500 units a day it's actually critical.
--
-- days_of_supply = stock_levels / units_sold
-- This tells us how many days of inventory remain
-- at the current sales rate. Lower = higher risk.
--
-- I also include availability because a product
-- can have physical stock but still fail to meet
-- demand if it frequently runs out mid-day.
-- Combining both metrics gives a fuller risk picture
-- than either column alone.
--
-- Risk tiers:
-- Critical  = BOTH days_of_supply low AND availability low
-- High Risk = EITHER metric is low
-- Low Risk  = either metric is borderline
-- Healthy   = both metrics look fine
-- ================================================

WITH stock_analysis AS (
    SELECT 
        sku,
        product_type,
        stock_levels,
        units_sold,
        availability,
        ROUND(stock_levels / NULLIF(units_sold, 0), 2) AS days_of_supply,
        CASE 
            WHEN stock_levels / NULLIF(units_sold, 0) < 0.05 AND availability < 40 THEN 'Critical'
            WHEN stock_levels / NULLIF(units_sold, 0) < 0.05 OR  availability < 40 THEN 'High Risk'
            WHEN stock_levels / NULLIF(units_sold, 0) < 0.10 OR  availability < 70 THEN 'Low Risk'
            ELSE 'Healthy'
        END AS stock_status
    FROM supply_chain_data
)
SELECT *
FROM stock_analysis
WHERE stock_status IN ('Critical', 'High Risk')
ORDER BY stock_status, days_of_supply;

-- ================================================
-- Q2: Which suppliers have the longest lead time? 
-- ================================================
-- Lead time directly impacts our ability to respond
-- to stockouts. A supplier with long lead times means
-- we need to order further in advance, leaving less
-- room for error.
--
-- I split lead time into two components:
-- avg_delivery_days   = avg time from order to delivery (supplier_delivery_days)
-- avg_production_days = avg time spent in manufacturing (production_days)
--
-- This tells me WHERE the delay is coming from —
-- is it a shipping problem or a production problem?
--
-- I also include delivery_range to measure consistency.
-- A supplier with a wide range is unpredictable even
-- if their average looks acceptable. In this example, all 
-- suppliers happen to have a similar range.
--
-- From these results, we can see that Supplier 2 and 3 
-- have the longest lead time at an average of 34.77 days.
-- ================================================

SELECT 
	supplier_name,
    count(sku) AS sku_count,
    ROUND(avg(supplier_delivery_days), 2) AS avg_delivery_days,
    ROUND(avg(production_days), 2) AS avg_production_days,
	ROUND(avg(supplier_delivery_days + production_days), 2) AS avg_total_lead_time,
    ROUND((MAX(supplier_delivery_days) - MIN(supplier_delivery_days)), 2) AS delivery_range
FROM supply_chain_data
GROUP BY supplier_name
ORDER BY avg_total_lead_time desc;

-- ================================================
-- Q3: What is the total inventory value per category?
-- ================================================
-- Revenue alone can be misleading — a category might
-- generate high total revenue simply because it has
-- more SKUs. revenue_per_sku normalizes this so we
-- can compare categories fairly regardless of size.
--
-- avg_stock shows whether high revenue categories
-- are also well stocked, or if they are at risk
-- of not being able to meet their own demand.
-- ================================================

SELECT 
    product_type,
    ROUND(SUM(revenue_generated), 0) AS total_revenue,
    COUNT(sku) AS total_skus,
    ROUND(AVG(stock_levels), 0) AS avg_stock,
    ROUND(SUM(revenue_generated) / COUNT(sku), 0) AS revenue_per_sku
FROM supply_chain_data
GROUP BY product_type
ORDER BY total_revenue DESC;

-- ================================================
-- Q4: Which products are ordered the most but still run out?
-- ================================================
-- High order quantities with low stock levels signals
-- a demand-supply mismatch — the product is popular
-- but the supply chain cannot keep up.
--
-- supply_gap = order_quantities - stock_levels
-- A large positive number means we are ordering a lot
-- but inventory is still being depleted faster than
-- it is being replenished. These are the SKUs most
-- likely to cause lost sales.
-- ================================================

SELECT 
	sku,
    order_quantities,
    stock_levels,
	(order_quantities - stock_levels) AS supply_gap
FROM 
	supply_chain_data
ORDER BY supply_gap DESC;

-- ================================================
-- Q5: Which suppliers have the highest defect rates?
-- ================================================
-- Defect rates directly impact inventory because
-- defective units cannot be sold, effectively reducing
-- usable stock levels below what the numbers show.
--
-- We include manufacturing_costs alongside defect rates
-- because a high cost AND high defect rate supplier
-- is the worst combination — expensive and unreliable.
--
-- The inspection results breakdown (Pass/Fail/Pending)
-- adds context beyond the average defect rate — a supplier
-- with many Pending inspections may be hiding a larger
-- problem that hasn't been caught yet.
-- ================================================

SELECT 
	supplier_name,
    ROUND(avg(defect_rates), 2) AS avg_defect_rate,
    ROUND(avg(manufacturing_costs), 2) AS avg_mfg_cost,
    count(SKU) as total_skus,
    SUM(CASE WHEN inspection_results = 'Pending' THEN 1 ELSE 0 END) AS total_pending,
	SUM(CASE WHEN inspection_results = 'Pass' THEN 1 ELSE 0 END) AS total_pass,
	SUM(CASE WHEN inspection_results = 'Fail' THEN 1 ELSE 0 END) AS total_fail
FROM
	supply_chain_data
GROUP BY supplier_name
ORDER BY avg_defect_rate DESC;