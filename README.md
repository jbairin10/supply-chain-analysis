# supply-chain-analysis

## Inventory Health & Stockout Risk Analysis

### Problem
Stockouts cost retailers an estimated 4% of revenue annually. 
This project identifies which products and suppliers pose the 
highest supply chain risk using transaction and inventory data.

### Tools
SQL (MySQL) · Python (pandas, matplotlib)

### Key Questions
1. Which products are at stockout risk?
2. Which suppliers have the longest lead times?
3. What is the total inventory value per category?
4. Which products are ordered the most but still run out?
5. Which suppliers have the highest defect rates?

### Key Findings

### 1. Inventory Risk
  41 out of 100 SKUs were classified as Critical or High Risk based on 
  a combined analysis of days of supply and availability scores. This 
  suggests that nearly half the product catalog is at risk of stockout 
  at any given time, which directly threatens revenue and customer 
  satisfaction.

### 2. Supplier Lead Times
Supplier 3 had the longest average total lead time at approximately 
20 days, making it the highest replenishment risk in the portfolio. 
Supplier 1 performed best at ~15 days. Notably, lead time 
consistency varied significantly across suppliers — a wide delivery 
range signals unreliability even when the average looks acceptable.

### 3. Revenue by Category
Skincare generated the highest total revenue at $241,628, followed 
by Haircare at $174,455 and Cosmetics at $161,521. However when 
normalizing by SKU count, the revenue per SKU gap between categories 
narrows — suggesting Skincare's lead is partly driven by having more 
products, not just higher performing ones.

### 4. Demand vs Supply Gap
Several SKUs showed order quantities significantly exceeding stock 
levels, indicating a persistent demand-supply mismatch. These 
products are being ordered in high volumes but inventory continues 
to be depleted faster than it is replenished — a key driver of the 
stockout risk identified in Q1.

### 5. Supplier Quality
Supplier 5 had the highest average defect rate at 2.67%, followed 
closely by Supplier 3 at 2.47% — the same supplier with the longest 
lead times. This double risk profile makes Supplier 3 the highest 
priority for review. Supplier 1 had the lowest defect rate at 1.80% 
and the shortest lead times, making it the most reliable supplier 
in the dataset.

### Files
- analysis.sql — all SQL queries
- notebook.ipynb — Python cleaning + visualization
- charts/ — exported visuals
