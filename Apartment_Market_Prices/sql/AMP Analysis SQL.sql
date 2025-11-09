-- ============================================
-- COMPREHENSIVE APARTMENT MARKET ANALYSIS
-- Data Cleaning + Sorting + Labeling + Business Insights
-- ============================================

-- First, let's see the current state of problematic data
SELECT 
    '=== DATA QUALITY ISSUES ===' AS Analysis_Section,
    COUNT(*) AS Total_Records,
    COUNT(CASE WHEN Tract_Median_Apartment_Contract_Rent_per_Unit < 100 THEN 1 END) AS Low_Rent_Records,
    COUNT(CASE WHEN ABS(Year_over_Year_Change_in_Rent_per_Unit) > 1000000 THEN 1 END) AS Scientific_Notation_Issues,
    COUNT(CASE WHEN Tract_Median_Apartment_Contract_Rent_per_Square_Foot < 0.50 THEN 1 END) AS Low_SqFt_Rent_Records
FROM [dbo].[Apartment_Market_Prices];

-- ============================================
-- STEP 1: BACKUP YOUR DATA (CRITICAL!)
-- ============================================
IF OBJECT_ID('[dbo].[Apartment_Market_Prices_BACKUP]', 'U') IS NOT NULL
    DROP TABLE [dbo].[Apartment_Market_Prices_BACKUP];

SELECT * INTO [dbo].[Apartment_Market_Prices_BACKUP] 
FROM [dbo].[Apartment_Market_Prices];

PRINT 'Backup created successfully!';

-- ============================================
-- STEP 2: FIX RENT VALUES (Multiply by 100)
-- ============================================

-- Fix rent per unit: $3.32 → $332 or $3,320 (adjust multiplier as needed)
UPDATE [dbo].[Apartment_Market_Prices]
SET Tract_Median_Apartment_Contract_Rent_per_Unit = Tract_Median_Apartment_Contract_Rent_per_Unit * 100
WHERE Tract_Median_Apartment_Contract_Rent_per_Unit > 0 
  AND Tract_Median_Apartment_Contract_Rent_per_Unit < 100;

PRINT 'Fixed low rent per unit values';

-- Fix rent per square foot if needed
UPDATE [dbo].[Apartment_Market_Prices]
SET Tract_Median_Apartment_Contract_Rent_per_Square_Foot = Tract_Median_Apartment_Contract_Rent_per_Square_Foot * 100
WHERE Tract_Median_Apartment_Contract_Rent_per_Square_Foot > 0 
  AND Tract_Median_Apartment_Contract_Rent_per_Square_Foot < 1.0;

PRINT 'Fixed low rent per square foot values';

-- ============================================
-- STEP 3: RECALCULATE YEAR-OVER-YEAR CHANGES
-- ============================================

WITH YearlyData AS (
    SELECT 
        OBJECTID,
        Year,
        Tract_Name,
        Community_Reporting_Area_Name,
        Tract_Median_Apartment_Contract_Rent_per_Unit AS Current_Rent_Unit,
        Tract_Median_Apartment_Contract_Rent_per_Square_Foot AS Current_Rent_SqFt,
        LAG(Tract_Median_Apartment_Contract_Rent_per_Unit) OVER (
            PARTITION BY Tract_Name, Community_Reporting_Area_Name 
            ORDER BY Year
        ) AS Previous_Rent_Unit,
        LAG(Tract_Median_Apartment_Contract_Rent_per_Square_Foot) OVER (
            PARTITION BY Tract_Name, Community_Reporting_Area_Name 
            ORDER BY Year
        ) AS Previous_Rent_SqFt
    FROM [dbo].[Apartment_Market_Prices]
)
UPDATE amp
SET 
    amp.Year_over_Year_Change_in_Rent_per_Unit = 
        CASE 
            WHEN yd.Previous_Rent_Unit IS NOT NULL AND yd.Previous_Rent_Unit > 0
            THEN (yd.Current_Rent_Unit - yd.Previous_Rent_Unit)
            ELSE NULL 
        END,
    amp.Year_over_Year_Change_in_Rent_per_Square_Foot = 
        CASE 
            WHEN yd.Previous_Rent_SqFt IS NOT NULL AND yd.Previous_Rent_SqFt > 0
            THEN ROUND(((yd.Current_Rent_SqFt - yd.Previous_Rent_SqFt) / yd.Previous_Rent_SqFt * 100), 2)
            ELSE NULL 
        END
FROM [dbo].[Apartment_Market_Prices] amp
INNER JOIN YearlyData yd ON amp.OBJECTID = yd.OBJECTID;

PRINT 'Recalculated Year-over-Year changes';

-- ============================================
-- STEP 4: UPDATE COST CATEGORIES
-- ============================================

UPDATE [dbo].[Apartment_Market_Prices]
SET Cost_Category = 
    CASE 
        WHEN Tract_Median_Apartment_Contract_Rent_per_Unit < 800 THEN 'Budget'
        WHEN Tract_Median_Apartment_Contract_Rent_per_Unit BETWEEN 800 AND 1200 THEN 'Affordable'
        WHEN Tract_Median_Apartment_Contract_Rent_per_Unit BETWEEN 1201 AND 1800 THEN 'Moderate'
        WHEN Tract_Median_Apartment_Contract_Rent_per_Unit BETWEEN 1801 AND 2500 THEN 'Premium'
        WHEN Tract_Median_Apartment_Contract_Rent_per_Unit > 2500 THEN 'Luxury'
        ELSE 'Unknown'
    END;

PRINT 'Updated Cost Categories';

-- ============================================
-- STEP 5: UPDATE YOY CHANGE CATEGORIES
-- ============================================

UPDATE [dbo].[Apartment_Market_Prices]
SET Year_over_Year_Change_in_Rent_Category = 
    CASE 
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot IS NULL THEN 'No Data'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot < -5 THEN 'Significant Decrease'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot BETWEEN -5 AND -2 THEN 'Moderate Decrease'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot BETWEEN -2 AND 2 THEN 'Stable'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot BETWEEN 2 AND 5 THEN 'Moderate Increase'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot BETWEEN 5 AND 10 THEN 'Significant Increase'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot > 10 THEN 'Rapid Growth'
        ELSE 'Unknown'
    END;

PRINT 'Updated YoY Change Categories';

-- ============================================
-- STEP 6: COMPREHENSIVE BUSINESS INSIGHTS
-- ============================================

-- 📊 INSIGHT 1: Market Overview by Year
SELECT 
    '1. MARKET OVERVIEW BY YEAR' AS Insight_Category,
    Year,
    COUNT(*) AS Total_Tracts,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent_Per_Unit,
    MIN(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Min_Rent,
    MAX(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Max_Rent,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Square_Foot) AS Avg_Rent_Per_SqFt,
    AVG(Year_over_Year_Change_in_Rent_per_Square_Foot) AS Avg_YoY_Change_Percent
FROM [dbo].[Apartment_Market_Prices]
GROUP BY Year
ORDER BY Year DESC;

-- 📈 INSIGHT 2: Top 10 Most Expensive Communities
SELECT TOP 10
    '2. MOST EXPENSIVE COMMUNITIES' AS Insight_Category,
    Community_Reporting_Area_Name,
    Year,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Square_Foot) AS Avg_Rent_Per_SqFt,
    COUNT(*) AS Number_of_Tracts
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
GROUP BY Community_Reporting_Area_Name, Year
ORDER BY Avg_Rent DESC;

-- 💰 INSIGHT 3: Top 10 Most Affordable Communities
SELECT TOP 10
    '3. MOST AFFORDABLE COMMUNITIES' AS Insight_Category,
    Community_Reporting_Area_Name,
    Year,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Square_Foot) AS Avg_Rent_Per_SqFt,
    COUNT(*) AS Number_of_Tracts
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
  AND Tract_Median_Apartment_Contract_Rent_per_Unit > 0
GROUP BY Community_Reporting_Area_Name, Year
ORDER BY Avg_Rent ASC;

-- 🚀 INSIGHT 4: Fastest Growing Markets (YoY)
SELECT TOP 10
    '4. FASTEST GROWING MARKETS' AS Insight_Category,
    Community_Reporting_Area_Name,
    Tract_Name,
    Year,
    Tract_Median_Apartment_Contract_Rent_per_Unit AS Current_Rent,
    Year_over_Year_Change_in_Rent_per_Unit AS Dollar_Change,
    Year_over_Year_Change_in_Rent_per_Square_Foot AS Percent_Change,
    Year_over_Year_Change_in_Rent_Category
FROM [dbo].[Apartment_Market_Prices]
WHERE Year_over_Year_Change_in_Rent_per_Square_Foot IS NOT NULL
  AND Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
ORDER BY Year_over_Year_Change_in_Rent_per_Square_Foot DESC;

-- 📉 INSIGHT 5: Markets with Declining Rents
SELECT TOP 10
    '5. DECLINING RENT MARKETS' AS Insight_Category,
    Community_Reporting_Area_Name,
    Tract_Name,
    Year,
    Tract_Median_Apartment_Contract_Rent_per_Unit AS Current_Rent,
    Year_over_Year_Change_in_Rent_per_Unit AS Dollar_Change,
    Year_over_Year_Change_in_Rent_per_Square_Foot AS Percent_Change,
    Year_over_Year_Change_in_Rent_Category
FROM [dbo].[Apartment_Market_Prices]
WHERE Year_over_Year_Change_in_Rent_per_Square_Foot < 0
  AND Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
ORDER BY Year_over_Year_Change_in_Rent_per_Square_Foot ASC;

-- 🏘️ INSIGHT 6: Cost Category Distribution
SELECT 
    '6. MARKET SEGMENTATION BY COST' AS Insight_Category,
    Cost_Category,
    COUNT(*) AS Number_of_Tracts,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent,
    MIN(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Min_Rent,
    MAX(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Max_Rent,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS Percent_of_Market
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
GROUP BY Cost_Category
ORDER BY Avg_Rent DESC;

-- 🔄 INSIGHT 7: YoY Change Distribution
SELECT 
    '7. YEAR-OVER-YEAR CHANGE DISTRIBUTION' AS Insight_Category,
    Year_over_Year_Change_in_Rent_Category,
    COUNT(*) AS Number_of_Tracts,
    AVG(Year_over_Year_Change_in_Rent_per_Square_Foot) AS Avg_Percent_Change,
    AVG(Year_over_Year_Change_in_Rent_per_Unit) AS Avg_Dollar_Change,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS Percent_of_Market
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
  AND Year_over_Year_Change_in_Rent_Category IS NOT NULL
GROUP BY Year_over_Year_Change_in_Rent_Category
ORDER BY Avg_Percent_Change DESC;

-- 🏢 INSIGHT 8: Mixed Income Housing Analysis
SELECT 
    '8. MIXED INCOME HOUSING IMPACT' AS Insight_Category,
    CASE 
        WHEN Mixed_Rate_or_Mixed_Income_Apartments_in_Tract > 0 THEN 'Has Mixed Income'
        ELSE 'No Mixed Income'
    END AS Mixed_Income_Status,
    COUNT(*) AS Number_of_Tracts,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent,
    AVG(Year_over_Year_Change_in_Rent_per_Square_Foot) AS Avg_YoY_Change_Percent
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
GROUP BY 
    CASE 
        WHEN Mixed_Rate_or_Mixed_Income_Apartments_in_Tract > 0 THEN 'Has Mixed Income'
        ELSE 'No Mixed Income'
    END;

-- 📍 INSIGHT 9: Community-Level Trends
SELECT 
    '9. COMMUNITY-LEVEL PERFORMANCE' AS Insight_Category,
    Community_Reporting_Area_Name,
    COUNT(*) AS Number_of_Tracts,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent,
    AVG(Year_over_Year_Change_in_Rent_per_Square_Foot) AS Avg_YoY_Change,
    MIN(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Min_Rent_in_Community,
    MAX(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Max_Rent_in_Community,
    MAX(Tract_Median_Apartment_Contract_Rent_per_Unit) - MIN(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Rent_Range
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
GROUP BY Community_Reporting_Area_Name
ORDER BY Avg_Rent DESC;

-- 🎯 INSIGHT 10: Investment Opportunities (High Growth + Affordable)
SELECT TOP 15
    '10. INVESTMENT OPPORTUNITIES' AS Insight_Category,
    Community_Reporting_Area_Name,
    Tract_Name,
    Year,
    Tract_Median_Apartment_Contract_Rent_per_Unit AS Current_Rent,
    Cost_Category,
    Year_over_Year_Change_in_Rent_per_Square_Foot AS Growth_Rate_Percent,
    Year_over_Year_Change_in_Rent_Category,
    CASE 
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot > 5 
             AND Tract_Median_Apartment_Contract_Rent_per_Unit < 1500 
        THEN 'High Potential'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot BETWEEN 2 AND 5 
             AND Tract_Median_Apartment_Contract_Rent_per_Unit < 1800 
        THEN 'Moderate Potential'
        ELSE 'Low Potential'
    END AS Investment_Rating
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = (SELECT MAX(Year) FROM [dbo].[Apartment_Market_Prices])
  AND Year_over_Year_Change_in_Rent_per_Square_Foot > 2
  AND Tract_Median_Apartment_Contract_Rent_per_Unit < 2000
ORDER BY Year_over_Year_Change_in_Rent_per_Square_Foot DESC;

-- ============================================
-- FINAL: CLEAN, SORTED, LABELED DATASET
-- ============================================

SELECT 
    Year,
    OBJECTID,
    GEOID,
    Tract_Label,
    Tract_Name,
    Community_Reporting_Area_Name,
    Community_Reporting_Area_ID,
    
    -- Rent Metrics (Cleaned)
    Tract_Median_Apartment_Contract_Rent_per_Square_Foot AS Rent_Per_SqFt,
    Tract_Median_Apartment_Contract_Rent_per_Unit AS Rent_Per_Unit,
    
    -- YoY Changes (Recalculated)
    Year_over_Year_Change_in_Rent_per_Square_Foot AS YoY_Change_Percent,
    Year_over_Year_Change_in_Rent_per_Unit AS YoY_Change_Dollars,
    
    -- Categories (Labeled)
    Cost_Category,
    Year_over_Year_Change_in_Rent_Category AS Market_Trend,
    
    -- Additional Info
    Mixed_Rate_or_Mixed_Income_Apartments_in_Tract AS Has_Mixed_Income,
    PROPERTIES,
    Shape_Area,
    Shape_Length,
    
    -- Calculated Fields for Analysis
    CASE 
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot > 5 
             AND Tract_Median_Apartment_Contract_Rent_per_Unit < 1500 
        THEN 'High Growth + Affordable'
        WHEN Tract_Median_Apartment_Contract_Rent_per_Unit > 2500 
        THEN 'Luxury Market'
        WHEN Year_over_Year_Change_in_Rent_per_Square_Foot < 0 
        THEN 'Declining Market'
        ELSE 'Stable Market'
    END AS Market_Classification

FROM [dbo].[Apartment_Market_Prices]
ORDER BY 
    Year DESC,
    Community_Reporting_Area_Name,
    Tract_Median_Apartment_Contract_Rent_per_Unit DESC;

PRINT '✅ Data cleaning and analysis complete!';
