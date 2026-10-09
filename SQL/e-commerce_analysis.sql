# Setting up The Database and Table in MySQL Server

CREATE DATABASE `ecommerce`;

# Create Table and Import Datasets

CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    unit_cost DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    shipping_cost_per_unit DECIMAL(10, 2),
    weight_lbs DECIMAL(10, 2),
    supplier VARCHAR(100)
);

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE '/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE orders (
	order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    `channel` VARCHAR(50),
    payment_method VARCHAR(50),
    region VARCHAR(50),
    items_ordered INT NOT NULL,
    primary_category VARCHAR(100),
    gross_revenue DECIMAl(10, 2) NOT NULL,
    discount_pct DECIMAL(10, 2) DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    shipping_cost DECIMAL(10, 2),
    product_cost DECIMAL(10, 2) NOT NULL,
    platform_fee DECIMAL(10, 2) DEFAULT 0.00,
    transaction_fee DECIMAL(10, 2) DEFAULT 0.00,
    returned VARCHAR(5) DEFAULT 'No',
    refund_amount DECIMAl(10, 2) DEFAULT 0.00,
    net_revenue DECIMAL(10, 2) NOT NULL,
    total_costs DECIMAL(10, 2) NOT NULL,
    profit DECIMAL(10, 2) NOT NULL
);

LOAD DATA LOCAL INFILE '/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE marketing_spend (
	`month` VARCHAR(7) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    spend DECIMAL(10, 2) NOT NULL,
    impressions INT NOT NULL,
    clicks INT NOT NULL,
    conversions INT NOT NULL,
    revenue_attributed DECIMAL(10, 2) NOT NULL,
    cpc DECIMAL(5, 2),
    cpa DECIMAL(5, 2),
    roas DECIMAL(5, 2),
    PRIMARY KEY (`month`, platform)
);

LOAD DATA LOCAL INFILE '/marketing_spend.csv'
INTO TABLE marketing_spend
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET GLOBAL local_infile = 0;
SHOW VARIABLES LIKE 'local_infile';

-- All the Datasets already cleaned and ready to analyze

# Question to answer and breakdown what types of analytics 

# -- Descriptive Analytics -- 
# 1. What is the average profit margin by product category?
# 2. How does profitability differ across sales channels?
# 3. What is the return rate by category and channel?
# 4. Estimate how much total revenue was lost to returns over the analysis period !
# 5. Which advertising platform delivering the best ROAS?

# -- Diagnostic Analytics -- 
# 1. Which categories are the most and least profitable, and what is driving the difference (product cost, shipping, returns, or discounts)?
# 2. Which channel has the best and worst profit per order after accounting for platform fees?
# 3. Are there any platforms where the company is spending money but not getting a positive return?

# -- Prescriptive Analytics -- 
# 1. If the CEO asked you to cut 20% of the marketing budget, which platforms and months would you recommend reducing spend on? Support your recommendation with data.
# 2. Create a one-page summary with your top 3 recommendations for improving profitability.
# 3. Include specific numbers (e.g., cutting X platform saves $Y with minimal revenue impact).


# - Descriptive Analytics - 
# 1. What is the average profit margin by product category?

SELECT 
    category,
    ROUND(AVG(profit), 2) AS avg_profit
FROM orders o 
INNER JOIN products p
    ON o.primary_category = p.category
GROUP BY category
ORDER BY avg_profit DESC;

## Electronics category is the highest average profit with $52.34, while Books is the lowest average profit with $9.41

# 2. How does profitability differ across sales channels?

SELECT 
	`channel`,
    ROUND(AVG(profit), 2) AS avg_profit
FROM orders
GROUP BY `channel`
ORDER BY avg_profit DESC;

## Mobile App is the highest profitability with $36.32, while Marketplace is the lowest profitability with $15.40

# 3. What is the return rate by category and channel?

SELECT 
	primary_category,
    `channel`,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN returned = 'Yes' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(AVG(CASE WHEN returned = 'Yes' THEN 1.0 ELSE 0.0 END) * 100, 2) AS returned_rate
FROM orders
GROUP BY primary_category, `channel`
ORDER BY returned_rate DESC;

## Social Commerce channel is the top 4 high return rate followed by Categories: Clothing, Books, Home & Kitchen and Food & Beverage --
-- with returned rate 13.33, 13.04, 13.04 and 12.50, --
-- while Marketplace channel is the top 2 low return rate followed by Categories: Food & Beverage and Sports --
-- with returned rate 1.61 and 1.92

# 4. Estimate how much total revenue was lost to returns over the analysis period !

SELECT 
	SUM(refund_amount) AS total_revenue_lost_to_return
FROM orders
WHERE returned = 'Yes';

## Total revenue was lost to returns over the analysis period is $20,582

# 5. Which advertising platform delivering the best ROAS?

SELECT
	platform,
    SUM(spend) AS total_spend,
    SUM(revenue_attributed) AS total_revenue,
    ROUND(SUM(revenue_attributed) / SUM(spend), 2) AS overall_roas
FROM marketing_spend
GROUP BY platform
ORDER BY overall_roas DESC;

## Tiktok Ads is delivering the best ROAS with 24.02%, while Email Marketing is delivering the worst ROAS with 4.81%

# - Diagnostics Analytics -
# 1. Which categories are the most and least profitable, and what is driving the difference (product cost, shipping, returns, or discounts)?

# -- Business Contribution
SELECT 
	primary_category,
    COUNT(order_id) AS total_order,
    SUM(profit) AS total_profit
FROM orders
GROUP BY primary_category
ORDER BY total_profit DESC;

## Electronics total order = 267 and total profit = $ 13,973 , while Books total order = 239 and total profit = $ 2,250

# -- Order-Level Profitability
SELECT
    primary_category,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND(SUM(profit) / SUM(net_revenue) * 100, 2) AS profit_margin
FROM orders
GROUP BY primary_category
ORDER BY profit_margin DESC;

## Electronics profit per order = $ 52.34, while Books profit per order = $ 9.41
## Electronics is the most profitable category, with a 31.13% profit margin, while Books is the least profitable at 11.94%.

# -- Unit-Level Profitability
SELECT
    primary_category,
    SUM(items_ordered) AS total_units,
    ROUND(SUM(gross_revenue) / SUM(items_ordered), 2) AS revenue_per_unit,
    ROUND(SUM(profit) / SUM(items_ordered), 2) AS profit_per_unit
FROM orders
GROUP BY primary_category
ORDER BY profit_per_unit DESC;

## Electronics revenue per unit = $ 104.29, while Books revenue per unit = $ 49.15
## Electronics profit per unit = $ 27.56, while Books profit per unit = $ 4.93

## Driving the difference (product cost, shipping, returns, or discounts)
SELECT
    primary_category,
    ROUND(AVG(net_revenue), 2) AS avg_net_revenue,
    ROUND(AVG(product_cost), 2) AS avg_product_cost,
    ROUND(SUM(product_cost) / SUM(gross_revenue) * 100, 2) AS product_cost_pct,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,
    ROUND(SUM(shipping_cost) / SUM(gross_revenue) * 100, 2) AS shipping_cost_pct,
    ROUND(AVG(refund_amount), 2) AS avg_refund_amount,
    ROUND(SUM(refund_amount) / SUM(gross_revenue) * 100, 2) AS refund_pct,
    ROUND(AVG(discount_amount), 2) AS avg_discount_amount,
    ROUND(SUM(discount_amount) / SUM(gross_revenue) * 100, 2) AS discount_pct
FROM orders
WHERE primary_category IN ('Electronics', 'Books')
GROUP BY primary_category;

## Electronics is the most profitable category, while Books is the least profitable. --
-- The difference is not primarily driven by order volume, as both categories have a similar number of orders. --
-- Books has a substantially higher shipping-cost burden relative to revenue (27.94% vs. 13.50%), --
-- followed by a higher refund burden (9.40% vs. 7.71%) and slightly higher product-cost burden (39.96% vs. 38.00%). --
-- Meanwhile, Electronics has a slightly higher discount burden but still achieves much higher profitability. --
-- Therefore, shipping costs appear to be the strongest contributing factor associated with the profitability gap, --
-- with refunds and product costs as secondary factors. ##

SELECT
    MIN(items_ordered) AS min_items,
    MAX(items_ordered) AS max_items,
    ROUND(AVG(items_ordered), 2) AS avg_items
FROM orders;

# 2. Which channel has the best and worst profit per order after accounting for platform fees?

SELECT
	`channel`,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(items_ordered), 2) AS avg_items_ordered,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND(AVG(platform_fee), 2) AS avg_platform_fee
FROM orders
GROUP BY `channel`
ORDER BY avg_profit_per_order DESC;

## Mobile App has the best profit per order with avg_profit_per_order $36.32, 
-- while Marketplace has the worst profit per order with avg_profit_per_order $15.40 after accounting for platform fees.
-- Marketplace has the higher platform fee than others this cause it's the worst profit per order after accounting for platform fees.

# 3. Are there any platforms where the company is spending money but not getting a positive return?

SELECT
	platform,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_attributed), 2) AS total_revenue,
    ROUND(SUM(revenue_attributed) / SUM(spend), 2) AS overall_roas,
    ROUND(SUM(revenue_attributed) - SUM(spend), 2) AS revenue_minus_spend
FROM marketing_spend
GROUP BY platform
ORDER BY overall_roas;

## Overall, all six marketing platforms generated a positive ROAS over the analysis period.
-- with Email Marketing having the lowest ROAS at 4.81 and TikTok Ads the highest at 24.02.

# - Let's take a look for a monthly roas

SELECT
	`month`,
	platform,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_attributed), 2) AS total_revenue,
    ROUND(SUM(revenue_attributed) / SUM(spend), 2) AS monthly_roas,
    ROUND(SUM(revenue_attributed) - SUM(spend), 2) AS revenue_minus_spend
FROM marketing_spend
GROUP BY `month`, platform
HAVING SUM(revenue_attributed) < SUM(spend)
ORDER BY monthly_roas;

## However, monthly analysis shows that Email Marketing had --
-- a negative return in December 2025, with a ROAS of 0.67.

# -- Perspective Analytics -- 
# 1. If the CEO asked you to cut 20% of the marketing budget, which platforms and months would you recommend reducing spend on? Support your recommendation with data.

SELECT
    ROUND(SUM(spend), 2) AS total_marketing_spend,
    ROUND(SUM(spend) * 0.20, 2) AS target_cut_20pct
FROM marketing_spend;

## Total marketing spend over the analysis period is $503,506, while target cut 20% of marketing budget is $100,701

SELECT
    `month`,
    platform,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_attributed), 2) AS total_revenue,
    ROUND(SUM(revenue_attributed) / SUM(spend), 2) AS monthly_roas
FROM marketing_spend
GROUP BY `month`, platform
ORDER BY monthly_roas ASC;


WITH ranked AS (
    SELECT
        `month`,
        platform,
        SUM(spend) AS total_spend,
        SUM(revenue_attributed) AS total_revenue,
        SUM(revenue_attributed) / SUM(spend) AS monthly_roas,
        SUM(SUM(spend)) OVER () * 0.20 AS target_cut,
        COALESCE(
            SUM(SUM(spend)) OVER (
                ORDER BY 
                    SUM(revenue_attributed) / SUM(spend) ASC,`month`,platform
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),0
        ) AS previous_cumulative_spend
    FROM marketing_spend
    GROUP BY `month`, platform
)
SELECT
    `month`,
    platform,
    ROUND(total_spend, 2) AS total_spend,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(monthly_roas, 2) AS monthly_roas,
    ROUND(LEAST(total_spend,GREATEST(0, target_cut - previous_cumulative_spend)), 2) AS recommended_cut
FROM ranked
WHERE previous_cumulative_spend < target_cut
ORDER BY monthly_roas ASC;

## To reduce the marketing budget by 20%, the company should prioritize reducing spending on Email Marketing in December 2025, --
-- October 2025, July 2025, and June 2024, followed by selected Facebook Ads campaigns with relatively low monthly ROAS.

SELECT *
FROM products;

SELECT *
FROM orders;

SELECT count(*)
FROM marketing_spend;



