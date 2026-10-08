-- Give a full analysis on this datasets Netflix_stock_action_clean.csv Netflix_stock_history_clean.csv Netflix_stock_info_clean.csv Netflix_stock_spilts_clean.csv
-- ============================================================
-- FULL NETFLIX STOCK ANALYSIS
-- Covers: stock history, actions (dividends), splits, and info
-- ============================================================

-- 1. STOCK HISTORY OVERVIEW: Basic Statistics
SELECT
    'Stock History Summary' AS analysis_section,
    MIN(Date) AS earliest_date,
    MAX(Date) AS latest_date,
    COUNT(*) AS total_trading_days,
    ROUND(MIN(`Close`), 2) AS min_close_price,
    ROUND(MAX(`Close`), 2) AS max_close_price,
    ROUND(AVG(`Close`), 2) AS avg_close_price,
    ROUND(MIN(`Open`), 2) AS min_open_price,
    ROUND(MAX(`Open`), 2) AS max_open_price,
    ROUND(AVG(`Open`), 2) AS avg_open_price,
    ROUND(MIN(`Low`), 2) AS min_low_price,
    ROUND(MAX(`High`), 2) AS max_high_price,
    ROUND(AVG(Volume), 0) AS avg_daily_volume,
    SUM(Volume) AS total_volume,
    ROUND(AVG(Daily_Return), 4) AS avg_daily_return,
    ROUND(AVG(Daily_Range), 2) AS avg_daily_range,
    ROUND(AVG(Open_Close_Change), 4) AS avg_open_close_change
FROM Netflix_stock_history_clean

-- 2. YEARLY PERFORMANCE BREAKDOWN
SELECT
    CONCAT('Yearly Performance - ', toString(Year)) AS analysis_section,
    MIN(Date) AS earliest_date,
    MAX(Date) AS latest_date,
    COUNT(*) AS total_trading_days,
    ROUND(MIN(`Close`), 2) AS min_close_price,
    ROUND(MAX(`Close`), 2) AS max_close_price,
    ROUND(AVG(`Close`), 2) AS avg_close_price,
    ROUND(MIN(`Open`), 2) AS min_open_price,
    ROUND(MAX(`Open`), 2) AS max_open_price,
    ROUND(AVG(`Open`), 2) AS avg_open_price,
    ROUND(MIN(`Low`), 2) AS min_low_price,
    ROUND(MAX(`High`), 2) AS max_high_price,
    ROUND(AVG(Volume), 0) AS avg_daily_volume,
    SUM(Volume) AS total_volume,
    ROUND(AVG(Daily_Return), 4) AS avg_daily_return,
    ROUND(AVG(Daily_Range), 2) AS avg_daily_range,
    ROUND(AVG(Open_Close_Change), 4) AS avg_open_close_change
FROM Netflix_stock_history_clean
GROUP BY Year
ORDER BY Year;

-- 3. MONTHLY PERFORMANCE BREAKDOWN
SELECT
    Year,
    Month,
    COUNT(*) AS trading_days,
    ROUND(MIN(`Close`), 2) AS min_close,
    ROUND(MAX(`Close`), 2) AS max_close,
    ROUND(AVG(`Close`), 2) AS avg_close,
    ROUND(SUM(Volume), 0) AS total_volume,
    ROUND(AVG(Daily_Return), 4) AS avg_daily_return,
    ROUND(AVG(Daily_Range), 2) AS avg_daily_range
FROM Netflix_stock_history_clean
GROUP BY Year, Month
ORDER BY Year, Month;

-- 4. RETURN OUTLIER ANALYSIS
SELECT
    Return_Outlier,
    COUNT(*) AS count,
    ROUND(AVG(Daily_Return), 4) AS avg_daily_return,
    ROUND(MIN(Daily_Return), 4) AS min_daily_return,
    ROUND(MAX(Daily_Return), 4) AS max_daily_return,
    ROUND(AVG(`Close`), 2) AS avg_close_price
FROM Netflix_stock_history_clean
GROUP BY Return_Outlier
ORDER BY Return_Outlier;

-- 5. TOP 10 BEST PERFORMING DAYS (by Daily Return)
SELECT
    Date,
    Year,
    Month,
    ROUND(`Open`, 2) AS open_price,
    ROUND(`Close`, 2) AS close_price,
    ROUND(Daily_Return, 4) AS daily_return,
    ROUND(Daily_Range, 2) AS daily_range,
    Volume,
    Return_Outlier
FROM Netflix_stock_history_clean
ORDER BY Daily_Return DESC
LIMIT 10;

-- 6. TOP 10 WORST PERFORMING DAYS (by Daily Return)
SELECT
    Date,
    Year,
    Month,
    ROUND(`Open`, 2) AS open_price,
    ROUND(`Close`, 2) AS close_price,
    ROUND(Daily_Return, 4) AS daily_return,
    ROUND(Daily_Range, 2) AS daily_range,
    Volume,
    Return_Outlier
FROM Netflix_stock_history_clean
ORDER BY Daily_Return ASC
LIMIT 10;

-- 7. HIGHEST VOLUME TRADING DAYS
SELECT
    Date,
    Year,
    Month,
    ROUND(`Close`, 2) AS close_price,
    Volume,
    ROUND(Daily_Return, 4) AS daily_return
FROM Netflix_stock_history_clean
ORDER BY Volume DESC
LIMIT 10;

-- 8. STOCK SPLITS ANALYSIS
SELECT
    Date AS split_date,
    `Stock Splits` AS split_ratio,
    'Stock Split Event' AS event_type
FROM Netflix_stock_spilts_clean
ORDER BY Date;

-- 9. DIVIDENDS ANALYSIS
SELECT
    Date AS action_date,
    Dividends AS dividend_amount,
    `Stock Splits` AS split_ratio,
    CASE
        WHEN Dividends > 0 THEN 'Dividend Payment'
        WHEN `Stock Splits` > 0 THEN 'Stock Split'
        ELSE 'Other Action'
    END AS action_type
FROM Netflix_stock_action_clean
WHERE Dividends > 0 OR `Stock Splits` > 0
ORDER BY Date;

-- 10. STOCK INFO / METADATA
SELECT
    c1 AS info_key,
    c2 AS info_value
FROM Netflix_stock_info_clean
ORDER BY c1;

-- 11. VOLATILITY ANALYSIS BY YEAR (Standard Deviation of Daily Returns)
SELECT
    Year,
    COUNT(*) AS trading_days,
    ROUND(AVG(Daily_Return), 4) AS avg_return,
    ROUND(stddevPop(Daily_Return), 4) AS return_volatility,
    ROUND(AVG(Daily_Range), 2) AS avg_price_range,
    ROUND(stddevPop(`Close`), 2) AS close_price_std_dev,
    ROUND(MIN(`Close`), 2) AS year_low,
    ROUND(MAX(`Close`), 2) AS year_high,
    ROUND(MAX(`Close`) - MIN(`Close`), 2) AS year_price_range
FROM Netflix_stock_history_clean
GROUP BY Year
ORDER BY Year;

-- 12. PRICE TREND: First vs Last Close Price Per Year (YoY Growth)
SELECT
    Year,
    ROUND(argMin(`Close`, Date), 2) AS first_close_of_year,
    ROUND(argMax(`Close`, Date), 2) AS last_close_of_year,
    ROUND(
        (argMax(`Close`, Date) - argMin(`Close`, Date)) / argMin(`Close`, Date) * 100,
        2
    ) AS yearly_return_pct
FROM Netflix_stock_history_clean
GROUP BY Year
ORDER BY Year;