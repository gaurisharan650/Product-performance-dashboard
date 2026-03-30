-- ============================================================
--   PRODUCT PERFORMANCE & USER JOURNEY ANALYSIS
--   Dataset : user_funnel_data_2.xlsx  |  674 records
--   Columns : User_id, Session_id, Stage, Timestamp, Product_id
--   Stages  : Visit → Signup → Add to Cart → Checkout → Purchase
--   Products: P1 – P10  |  Users: 200  |  Period: Jan 2024
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE & TABLE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS product_performance;
USE product_performance;

DROP TABLE IF EXISTS user_funnel;

CREATE TABLE user_funnel (
    User_id     INT,
    Session_id  VARCHAR(20),
    Stage       VARCHAR(50),
    Timestamp   DATETIME,
    Product_id  VARCHAR(10)
);


-- ============================================================
-- SECTION 2: DATA EXPLORATION
-- ============================================================

SELECT * FROM user_funnel LIMIT 10;

SELECT COUNT(*) AS Total_Records FROM user_funnel;

SELECT COUNT(DISTINCT User_id) AS Total_Users FROM user_funnel;

SELECT COUNT(DISTINCT Session_id) AS Total_Sessions FROM user_funnel;

SELECT COUNT(DISTINCT Product_id) AS Total_Products FROM user_funnel;

SELECT MIN(Timestamp) AS Start_Date, MAX(Timestamp) AS End_Date FROM user_funnel;

SELECT DISTINCT Stage FROM user_funnel ORDER BY Stage;

SELECT Stage, COUNT(*) AS Total_Records
FROM user_funnel
GROUP BY Stage
ORDER BY Total_Records DESC;


-- ============================================================
-- SECTION 3: FUNNEL ANALYSIS
-- ============================================================

-- Users at each stage
SELECT
    Stage,
    COUNT(DISTINCT User_id) AS Unique_Users
FROM user_funnel
GROUP BY Stage
ORDER BY
    CASE Stage
        WHEN 'Visit'       THEN 1
        WHEN 'Signup'      THEN 2
        WHEN 'Add to Cart' THEN 3
        WHEN 'Checkout'    THEN 4
        WHEN 'Purchase'    THEN 5
    END;

-- Funnel with drop-off
SELECT
    Stage,
    Unique_Users,
    LAG(Unique_Users) OVER (ORDER BY Stage_Order) AS Previous_Stage_Users,
    LAG(Unique_Users) OVER (ORDER BY Stage_Order) - Unique_Users AS Drop_Off_Count,
    ROUND((1 - Unique_Users / LAG(Unique_Users) OVER (ORDER BY Stage_Order)) * 100, 2) AS Drop_Off_Pct
FROM (
    SELECT
        Stage,
        COUNT(DISTINCT User_id) AS Unique_Users,
        CASE Stage
            WHEN 'Visit'       THEN 1
            WHEN 'Signup'      THEN 2
            WHEN 'Add to Cart' THEN 3
            WHEN 'Checkout'    THEN 4
            WHEN 'Purchase'    THEN 5
        END AS Stage_Order
    FROM user_funnel
    GROUP BY Stage
) AS funnel_base
ORDER BY Stage_Order;

-- Step-to-step conversion rates
SELECT 'Visit → Signup' AS Funnel_Step,
    ROUND(COUNT(DISTINCT CASE WHEN Stage = 'Signup' THEN User_id END) * 100.0 /
          COUNT(DISTINCT CASE WHEN Stage = 'Visit'  THEN User_id END), 2) AS Conversion_Rate_Pct
FROM user_funnel
UNION ALL
SELECT 'Signup → Add to Cart',
    ROUND(COUNT(DISTINCT CASE WHEN Stage = 'Add to Cart' THEN User_id END) * 100.0 /
          COUNT(DISTINCT CASE WHEN Stage = 'Signup'      THEN User_id END), 2)
FROM user_funnel
UNION ALL
SELECT 'Add to Cart → Checkout',
    ROUND(COUNT(DISTINCT CASE WHEN Stage = 'Checkout'    THEN User_id END) * 100.0 /
          COUNT(DISTINCT CASE WHEN Stage = 'Add to Cart' THEN User_id END), 2)
FROM user_funnel
UNION ALL
SELECT 'Checkout → Purchase',
    ROUND(COUNT(DISTINCT CASE WHEN Stage = 'Purchase'  THEN User_id END) * 100.0 /
          COUNT(DISTINCT CASE WHEN Stage = 'Checkout'  THEN User_id END), 2)
FROM user_funnel;

-- Overall conversion rate
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN Stage = 'Purchase' THEN User_id END) * 100.0 /
        COUNT(DISTINCT CASE WHEN Stage = 'Visit'    THEN User_id END),
    2) AS Overall_Conversion_Rate_Pct
FROM user_funnel;

-- Users who completed all 5 stages
SELECT COUNT(*) AS Users_Completed_Full_Journey
FROM (
    SELECT User_id FROM user_funnel
    GROUP BY User_id
    HAVING COUNT(DISTINCT Stage) = 5
) AS full_journey;


-- ============================================================
-- SECTION 4: PRODUCT PERFORMANCE
-- ============================================================

-- Total interactions per product
SELECT
    Product_id,
    COUNT(*)                    AS Total_Interactions,
    COUNT(DISTINCT User_id)     AS Unique_Users,
    COUNT(DISTINCT Session_id)  AS Unique_Sessions
FROM user_funnel
GROUP BY Product_id
ORDER BY Total_Interactions DESC;

-- Product performance at each funnel stage
SELECT
    Product_id,
    COUNT(DISTINCT CASE WHEN Stage = 'Visit'       THEN User_id END) AS Visit_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Signup'      THEN User_id END) AS Signup_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Add to Cart' THEN User_id END) AS Cart_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Checkout'    THEN User_id END) AS Checkout_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Purchase'    THEN User_id END) AS Purchase_Users
FROM user_funnel
GROUP BY Product_id
ORDER BY Purchase_Users DESC;

-- Product conversion rate
SELECT
    Product_id,
    COUNT(DISTINCT CASE WHEN Stage = 'Visit'    THEN User_id END) AS Visit_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Purchase' THEN User_id END) AS Purchase_Users,
    ROUND(
        COUNT(DISTINCT CASE WHEN Stage = 'Purchase' THEN User_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN Stage = 'Visit' THEN User_id END), 0),
    2) AS Product_Conversion_Rate_Pct
FROM user_funnel
GROUP BY Product_id
ORDER BY Product_Conversion_Rate_Pct DESC;


-- ============================================================
-- SECTION 5: USER BEHAVIOR ANALYSIS
-- ============================================================

-- Stages completed per user
SELECT
    User_id,
    COUNT(DISTINCT Stage)   AS Stages_Completed,
    MIN(Timestamp)          AS First_Activity,
    MAX(Timestamp)          AS Last_Activity
FROM user_funnel
GROUP BY User_id
ORDER BY Stages_Completed DESC;

-- User journey duration
SELECT
    User_id,
    MIN(Timestamp) AS Journey_Start,
    MAX(Timestamp) AS Journey_End,
    TIMESTAMPDIFF(MINUTE, MIN(Timestamp), MAX(Timestamp)) AS Journey_Duration_Minutes
FROM user_funnel
GROUP BY User_id
ORDER BY Journey_Duration_Minutes DESC;

-- Average journey duration
SELECT
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, Journey_Start, Journey_End)), 2) AS Avg_Journey_Duration_Minutes
FROM (
    SELECT User_id, MIN(Timestamp) AS Journey_Start, MAX(Timestamp) AS Journey_End
    FROM user_funnel
    GROUP BY User_id
) AS durations;


-- ============================================================
-- SECTION 6: TIME-BASED ANALYSIS
-- ============================================================

-- Daily event volume
SELECT
    DATE(Timestamp)         AS Activity_Date,
    COUNT(*)                AS Total_Events,
    COUNT(DISTINCT User_id) AS Active_Users
FROM user_funnel
GROUP BY DATE(Timestamp)
ORDER BY Activity_Date;

-- Peak activity hours
SELECT
    HOUR(Timestamp) AS Hour_of_Day,
    COUNT(*)        AS Total_Events
FROM user_funnel
GROUP BY HOUR(Timestamp)
ORDER BY Hour_of_Day;

-- Weekly breakdown
SELECT
    WEEK(Timestamp)         AS Week_Number,
    COUNT(*)                AS Total_Events,
    COUNT(DISTINCT User_id) AS Active_Users
FROM user_funnel
GROUP BY WEEK(Timestamp)
ORDER BY Week_Number;



-- SECTION 7: KPI SUMMARY

SELECT
    COUNT(*)                                                         AS Total_Records,
    COUNT(DISTINCT User_id)                                          AS Total_Users,
    COUNT(DISTINCT Session_id)                                       AS Total_Sessions,
    COUNT(DISTINCT Product_id)                                       AS Total_Products,
    COUNT(DISTINCT CASE WHEN Stage = 'Visit'       THEN User_id END) AS Visit_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Signup'      THEN User_id END) AS Signup_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Add to Cart' THEN User_id END) AS Cart_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Checkout'    THEN User_id END) AS Checkout_Users,
    COUNT(DISTINCT CASE WHEN Stage = 'Purchase'    THEN User_id END) AS Purchase_Users,
    ROUND(
        COUNT(DISTINCT CASE WHEN Stage = 'Purchase' THEN User_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN Stage = 'Visit' THEN User_id END), 0),
    2)                                                               AS Overall_Conversion_Pct,
    MIN(Timestamp)                                                   AS Data_Start_Date,
    MAX(Timestamp)                                                   AS Data_End_Date
FROM user_funnel;

-- END OF SCRIPT
