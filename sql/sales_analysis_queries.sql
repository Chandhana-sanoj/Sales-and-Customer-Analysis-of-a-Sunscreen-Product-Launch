/*
Project: Sales and Customer Analysis of a Sunscreen Product Launch
Database: SunscreenSalesDB
*/
use SunscreenSalesDB;
GO

/* =========================================
   DATA VALIDATION
   ========================================= */

-- Total number of records
SELECT COUNT(*) FROM Sales_Data;

-- Check missing Order_Value
SELECT COUNT(*) 
FROM Sales_Data
WHERE Order_Value IS NULL;

/* =========================================
   DATA PREPARATION
   ========================================= */

-- Fill missing Order_Value using Units_Purchased and Price_per_Unit
UPDATE Sales_Data
SET Order_Value = Units_Purchased * Price_per_Unit
WHERE Order_Value IS NULL;

-- Verify no NULL values remain
SELECT COUNT(*) AS Null_Order_Value_Count
FROM Sales_Data
WHERE Order_Value IS NULL;


/* =========================================
   LAUNCH IMPACT ANALYSIS
   ========================================= */

-- Question 1: What was the average daily sales before launch?

SELECT 
    AVG(Daily_Total) AS Avg_Daily_Sales_Before
FROM (
    SELECT 
        Date,
        SUM(Order_Value) AS Daily_Total
    FROM Sales_Data
    WHERE Launch_Period = 'Before Launch'
    GROUP BY Date
) AS DailySales;

-- Question 2: What was the average daily sales after launch?

SELECT 
    AVG(Daily_Total) AS Avg_Daily_Sales_After
FROM (
    SELECT 
        Date,
        SUM(Order_Value) AS Daily_Total
    FROM Sales_Data
    WHERE Launch_Period = 'After Launch'
    GROUP BY Date
) AS DailySales;

-- Question 3: Percentage growth in average daily sales after launch

WITH DailySales AS (
    SELECT 
        Date,
        Launch_Period,
        SUM(Order_Value) AS Daily_Total
    FROM Sales_Data
    GROUP BY Date, Launch_Period
)
SELECT
    AVG(CASE WHEN Launch_Period = 'Before Launch' THEN Daily_Total END) AS Avg_Before_Launch,
    AVG(CASE WHEN Launch_Period = 'After Launch' THEN Daily_Total END) AS Avg_After_Launch,

    CAST(ROUND(
        (
            AVG(CASE WHEN Launch_Period = 'After Launch' THEN Daily_Total END) -
            AVG(CASE WHEN Launch_Period = 'Before Launch' THEN Daily_Total END)
        ) * 100.0 /
        AVG(CASE WHEN Launch_Period = 'Before Launch' THEN Daily_Total END)
    , 2) AS DECIMAL(10,2)) AS Percentage_Growth

FROM DailySales;

/* =========================================
   PRODUCT PERFORMANCE
   ========================================= */

-- Question 1: Which variant generated the highest revenue?

SELECT 
    Variant_Name,
    SUM(Order_Value) AS Total_Revenue
FROM Sales_Data
GROUP BY Variant_Name
ORDER BY Total_Revenue DESC;

-- Question 2: Which variant sold the most units?

SELECT 
    Variant_Name,
    SUM(Units_Purchased) AS Total_Units_Sold
FROM Sales_Data
GROUP BY Variant_Name
ORDER BY Total_Units_Sold DESC;

-- Question 3: Which variant generated the highest profit?

SELECT 
    s.Variant_Name,
    SUM((p.Price_per_Unit - p.Cost_per_Unit) * s.Units_Purchased) AS Total_Profit
FROM Sales_Data s
JOIN Product_Table p
    ON s.Variant_Name = p.Variant_Name
GROUP BY s.Variant_Name
ORDER BY Total_Profit DESC;


/* =========================================
   CUSTOMER BEHAVIOUR
   ========================================= */

   -- Question 1: What percentage of customers are repeat customers?

SELECT 
    Customer_Type,
    COUNT(*) AS Total_Orders,
    CAST(
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Sales_Data), 2)
        AS DECIMAL(5,2)
    ) AS Percentage
FROM Sales_Data
GROUP BY Customer_Type;

-- Question 2: Do repeat customers generate more revenue than new customers?

SELECT
    Customer_Type,
    SUM(Order_Value) AS Total_Revenue
FROM Sales_Data
GROUP BY Customer_Type
ORDER BY Total_Revenue DESC;


/* =========================================
   AGE GROUP INSIGHTS
   ========================================= */

-- Question 1: Which age group purchased the most units?

SELECT 
    Age_Group,
    SUM(Units_Purchased) AS Total_Units
FROM Sales_Data
GROUP BY Age_Group
ORDER BY Total_Units DESC;

-- Question 2: Which age group spends the most per order?

SELECT 
    Age_Group,
    ROUND(AVG(Order_Value), 2) AS Avg_Order_Value
FROM Sales_Data
GROUP BY Age_Group
ORDER BY Avg_Order_Value DESC;

-- Question 3: Which variant is most popular among each age group?

SELECT 
    Age_Group,
    Variant_Name,
    SUM(Units_Purchased) AS Total_Units
FROM Sales_Data
GROUP BY Age_Group, Variant_Name
ORDER BY Age_Group, Total_Units DESC;

/* =========================================
   CHANNEL EFFECTIVENESS
   ========================================= */

-- Question 1: Which channel generates more revenue— Online or In-store?

SELECT
    Channel,
    SUM(Order_Value) AS Total_Revenue
FROM Sales_Data
GROUP BY Channel
ORDER BY Total_Revenue DESC;

-- Question 2: Which channel has higher average order value?

SELECT
    Channel,
    ROUND(AVG(Order_Value), 2) AS Avg_Order_Value
FROM Sales_Data
GROUP BY Channel
ORDER BY Avg_Order_Value DESC;

-- Question 3: How does channel performance change after launch?

SELECT
    Channel,
    Launch_Period,
    SUM(Order_Value) AS Total_Revenue
FROM Sales_Data
GROUP BY Channel, Launch_Period
ORDER BY Channel, Launch_Period;

/* =========================================
   REGIONAL PERFORMANCE
   ========================================= */

-- Question 1: Which region generates the highest revenue?

SELECT
    Region,
    SUM(Order_Value) AS Total_Revenue
FROM Sales_Data
GROUP BY Region
ORDER BY Total_Revenue DESC;

-- Question 2: Which region shows the fastest growth after launch?

WITH RegionalSales AS (
    SELECT
        Region,
        Launch_Period,
        SUM(Order_Value) AS Total_Revenue
    FROM Sales_Data
    GROUP BY Region, Launch_Period
)

SELECT
    Region,
    SUM(CASE WHEN Launch_Period = 'Before Launch' THEN Total_Revenue END) AS Before_Launch,
    SUM(CASE WHEN Launch_Period = 'After Launch' THEN Total_Revenue END) AS After_Launch,
    ROUND(
        (
            SUM(CASE WHEN Launch_Period = 'After Launch' THEN Total_Revenue END) -
            SUM(CASE WHEN Launch_Period = 'Before Launch' THEN Total_Revenue END)
        ) * 100.0 /
        SUM(CASE WHEN Launch_Period = 'Before Launch' THEN Total_Revenue END)
    , 2) AS Growth_Percentage
FROM RegionalSales
GROUP BY Region
ORDER BY Growth_Percentage DESC;
