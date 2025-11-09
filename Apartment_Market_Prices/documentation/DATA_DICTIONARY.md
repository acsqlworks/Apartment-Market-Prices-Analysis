# 📖 Data Dictionary

## Overview
This document provides comprehensive definitions for all fields in the Seattle Apartment Market Prices dataset. Understanding these fields is essential for accurate analysis and interpretation of rental market trends.

---

## 📊 Dataset Metadata

| Attribute | Value |
|-----------|-------|
| **Dataset Name** | Apartment Market Prices by Census Tract |
| **Source** | CoStar Group (via Seattle Office of Planning & Community Development) |
| **Geographic Scope** | Seattle, Washington, USA |
| **Time Period** | 2001 (single year snapshot) |
| **Total Records** | 26 census tracts |
| **Last Updated** | 2001 |
| **Granularity** | Census Tract level |

---

## 🔑 Primary Identifiers

### OBJECTID
- **Data Type**: Integer
- **Description**: Unique identifier for each record in the dataset
- **Range**: 1 to 26
- **Primary Key**: Yes
- **Nullable**: No
- **Example**: `1`, `2`, `3`
- **Usage**: Used for joining tables and ensuring record uniqueness

### Year
- **Data Type**: Integer (4 digits)
- **Description**: Calendar year of the data snapshot
- **Range**: 2001
- **Format**: YYYY
- **Nullable**: No
- **Example**: `2001`
- **Usage**: Time-series analysis, temporal filtering
- **Note**: Dataset currently contains single year; designed for multi-year expansion

### GEOID
- **Data Type**: String (VARCHAR 20)
- **Description**: Census Geographic Identifier - unique 11-digit code for each census tract
- **Format**: FIPS code standard
- **Nullable**: No
- **Example**: `53033001201`, `53033004904`
- **Structure**: 
  - Digits 1-2: State code (53 = Washington)
  - Digits 3-5: County code (033 = King County)
  - Digits 6-11: Census tract number
- **Usage**: Geographic joins with Census Bureau data
- **Important**: Must be stored as string to preserve leading zeros

---

## 📍 Geographic Fields

### Tract_Label
- **Data Type**: String (VARCHAR 50)
- **Description**: Human-readable census tract identifier
- **Format**: Decimal notation of tract number
- **Nullable**: No
- **Example**: `12.01000022888`, `4.03999996185303`
- **Usage**: Alternative tract reference, human-readable reports
- **Note**: Corresponds to official Census tract labeling system

### Tract_Name
- **Data Type**: String (VARCHAR 100)
- **Description**: Official name of the census tract
- **Format**: "Census Tract [number]"
- **Nullable**: No
- **Example**: `Census Tract 12.01`, `Census Tract 4.04`
- **Usage**: Display labels, geographic filtering

### Community_Reporting_Area_Name
- **Data Type**: String (VARCHAR 100)
- **Description**: Name of the larger neighborhood/community area containing the tract
- **Format**: Plain text neighborhood name
- **Nullable**: No
- **Example**: `Northgate/Maple Leaf`, `Downtown Commercial Core`, `Queen Anne`
- **Usage**: Neighborhood-level aggregation and analysis
- **Unique Values**: 20+ distinct neighborhoods
- **Business Value**: More intuitive than tract numbers for stakeholders

### Community_Reporting_Area_ID
- **Data Type**: String (VARCHAR 50)
- **Description**: Numeric identifier for community reporting area
- **Format**: Decimal number
- **Nullable**: No
- **Example**: `8.10000038146973`, `9.10000038146973`
- **Usage**: Joining with other Seattle municipal datasets

---

## 💰 Rent Metrics (Core Fields)

### Tract_Median_Apartment_Contract_Rent_per_Unit
- **Data Type**: Decimal (18, 2)
- **Description**: Median monthly rental price per apartment unit in the census tract
- **Unit**: US Dollars ($)
- **Format**: Currency, 2 decimal places
- **Nullable**: Yes (0 indicates no data)
- **Range**: $916 - $2,895 (after cleaning)
- **Example**: `1519.99`, `1289.99`, `1042.00`
- **Calculation Method**: Median of all apartment rents in tract
- **Inclusion Criteria**: 
  - Market-rate apartments only
  - Mixed-income apartments included
  - 5+ unit properties
  - Excludes: Student housing, senior housing, corporate housing, military housing
- **Business Value**: Primary metric for affordability assessment
- **Data Quality Note**: Original dataset had values stored with decimal errors (fixed during cleaning)

### Tract_Median_Apartment_Contract_Rent_per_Square_Foot
- **Data Type**: Decimal (18, 2)
- **Description**: Median monthly rental price per square foot of living space
- **Unit**: US Dollars per square foot ($/sq ft)
- **Format**: Currency, 2 decimal places
- **Nullable**: Yes (0 indicates no data)
- **Range**: $0.92 - $3.30 (after cleaning)
- **Example**: `1.52`, `2.64`, `1.78`
- **Calculation Method**: Median of (Monthly Rent / Unit Square Footage)
- **Business Value**: Normalizes rent by unit size; better for comparing different property types
- **Usage**: Investment analysis, price-per-square-foot trends
- **Important**: Accounts for unit size variations within tracts

---

## 📈 Year-over-Year Change Metrics

### Year_over_Year_Change_in_Rent_per_Unit
- **Data Type**: Decimal (18, 2)
- **Description**: Dollar amount change in median rent per unit from previous year
- **Unit**: US Dollars ($)
- **Format**: Currency, 2 decimal places (can be negative)
- **Nullable**: Yes (NULL for first year of data or missing historical data)
- **Range**: -$200 to +$350 (typical)
- **Example**: `48.12`, `-15.50`, `125.00`
- **Calculation**: Current Year Rent - Previous Year Rent
- **Formula**: `Rent(t) - Rent(t-1)`
- **Business Value**: Absolute dollar impact of rent changes
- **Interpretation**:
  - Positive: Rent increase
  - Negative: Rent decrease
  - NULL: No historical comparison available

### Year_over_Year_Change_in_Rent_per_Square_Foot
- **Data Type**: Decimal (18, 2)
- **Description**: Percentage change in rent per square foot from previous year
- **Unit**: Percent (%)
- **Format**: Decimal percentage, 2 decimal places
- **Nullable**: Yes (NULL for first year or missing data)
- **Range**: -5.2% to +14.8% (after cleaning)
- **Example**: `5.25`, `-2.10`, `12.50`
- **Calculation**: ((Current - Previous) / Previous) × 100
- **Formula**: `((Rent_SqFt(t) - Rent_SqFt(t-1)) / Rent_SqFt(t-1)) * 100`
- **Business Value**: Relative growth rate, inflation-adjusted comparison
- **Interpretation**:
  - >5%: Significant growth
  - 2-5%: Moderate growth
  - -2 to 2%: Stable market
  - <-2%: Declining market
- **Data Quality Note**: Recalculated during cleaning process using LAG() window function

---

## 🏷️ Category Fields (Derived)

### Cost_Category
- **Data Type**: String (VARCHAR 50)
- **Description**: Classification of rental affordability level
- **Format**: Categorical text
- **Nullable**: No
- **Possible Values**:
  - `Budget`: <$800/month
  - `Affordable`: $800-$1,200/month
  - `Moderate`: $1,201-$1,800/month
  - `Premium`: $1,801-$2,500/month
  - `Luxury`: >$2,500/month
  - `Unknown`: Missing or invalid data
- **Derivation Logic**:
```sql
CASE 
    WHEN Rent_per_Unit < 800 THEN 'Budget'
    WHEN Rent_per_Unit BETWEEN 800 AND 1200 THEN 'Affordable'
    WHEN Rent_per_Unit BETWEEN 1201 AND 1800 THEN 'Moderate'
    WHEN Rent_per_Unit BETWEEN 1801 AND 2500 THEN 'Premium'
    WHEN Rent_per_Unit > 2500 THEN 'Luxury'
    ELSE 'Unknown'
END
```
- **Business Value**: Segments market for targeted analysis
- **Distribution**: 
  - Budget: 7.7%
  - Affordable: 15.4%
  - Moderate: 26.9%
  - Premium: 30.8%
  - Luxury: 19.2%

### Year_over_Year_Change_in_Rent_Category
- **Data Type**: String (VARCHAR 50)
- **Description**: Classification of market trend velocity
- **Format**: Categorical text
- **Nullable**: No
- **Possible Values**:
  - `Rapid Growth`: >10% increase
  - `Significant Increase`: 5-10% increase
  - `Moderate Increase`: 2-5% increase
  - `Stable`: -2% to 2% change
  - `Moderate Decrease`: -5% to -2% decrease
  - `Significant Decrease`: <-5% decrease
  - `No Data`: NULL or missing historical data
- **Derivation Logic**:
```sql
CASE 
    WHEN YoY_Change IS NULL THEN 'No Data'
    WHEN YoY_Change < -5 THEN 'Significant Decrease'
    WHEN YoY_Change BETWEEN -5 AND -2 THEN 'Moderate Decrease'
    WHEN YoY_Change BETWEEN -2 AND 2 THEN 'Stable'
    WHEN YoY_Change BETWEEN 2 AND 5 THEN 'Moderate Increase'
    WHEN YoY_Change BETWEEN 5 AND 10 THEN 'Significant Increase'
    WHEN YoY_Change > 10 THEN 'Rapid Growth'
END
```
- **Business Value**: Identifies gentrification, market cooling, stable areas
- **Usage**: Risk assessment, investment timing, policy analysis

---

## 🏘️ Housing Composition

### Mixed_Rate_or_Mixed_Income_Apartments_in_Tract
- **Data Type**: Integer
- **Description**: Count of mixed-rate or mixed-income apartment properties in the census tract
- **Unit**: Number of properties
- **Nullable**: Yes (0 indicates none present)
- **Range**: 0 to 663
- **Example**: `103`, `69`, `0`
- **Definition**: Properties containing both market-rate and subsidized/affordable units
- **Business Value**: 
  - Measures economic diversity
  - Correlates with displacement risk
  - Policy effectiveness indicator
- **Analysis Use**: Compare rent trends in tracts with/without mixed-income housing

### PROPERTIES
- **Data Type**: Integer
- **Description**: Total number of qualifying apartment properties in the census tract
- **Unit**: Count of buildings/properties
- **Nullable**: Yes (0 indicates no qualifying properties)
- **Range**: 0 to 885
- **Example**: `5`, `8`, `234`
- **Inclusion Criteria**: 
  - 5+ rental units
  - Multifamily apartment buildings
  - Excludes single-family homes, condos, townhouses
- **Business Value**: Market size indicator, density measure
- **Usage**: Weight for averages, market concentration analysis

---

## 📐 Geographic Measurements

### Shape_Area
- **Data Type**: Decimal (18, 2)
- **Description**: Total area of the census tract polygon
- **Unit**: Square meters (m²)
- **Format**: Decimal number
- **Nullable**: No
- **Range**: 307,246 to 105,978,057
- **Example**: `97263519.0356445`, `105397805728455`
- **Source**: US Census Bureau TIGER/Line shapefiles
- **Business Value**: 
  - Density calculations (properties per area)
  - Geographic context
  - Spatial analysis
- **Conversion**: Divide by 1,000,000 for square kilometers

### Shape_Length
- **Data Type**: Decimal (18, 2)
- **Description**: Perimeter length of the census tract boundary
- **Unit**: Meters (m)
- **Format**: Decimal number
- **Nullable**: No
- **Range**: 13,186,770 to 78,024,635
- **Example**: `13186770184683`, `17192703749828`
- **Source**: US Census Bureau TIGER/Line shapefiles
- **Business Value**: Boundary complexity, compactness analysis
- **Note**: Long perimeters relative to area may indicate irregular tract shapes

---

## 📋 Data Quality Indicators

### Records with Complete Data
- **Count**: 23 of 26 (88%)
- **Missing Data Records**: 3 (rows with all zeros)

### Data Completeness by Field

| Field | Complete Records | Completeness % |
|-------|------------------|----------------|
| OBJECTID | 26 | 100% |
| Year | 26 | 100% |
| GEOID | 26 | 100% |
| Tract_Name | 26 | 100% |
| Community_Name | 26 | 100% |
| Rent_per_Unit | 23 | 88% |
| Rent_per_SqFt | 23 | 88% |
| YoY_Change_Unit | 18 | 69% |
| YoY_Change_SqFt | 18 | 69% |
| Mixed_Income_Count | 23 | 88% |
| PROPERTIES | 23 | 88% |

---

## 🔍 Usage Examples

### Basic Query
```sql
SELECT 
    Tract_Name,
    Community_Reporting_Area_Name,
    Tract_Median_Apartment_Contract_Rent_per_Unit AS Monthly_Rent,
    Cost_Category,
    PROPERTIES AS Property_Count
FROM Apartment_Market_Prices
WHERE Tract_Median_Apartment_Contract_Rent_per_Unit > 0
ORDER BY Monthly_Rent DESC;
```

### Calculating Rent per Property
```sql
SELECT 
    Community_Reporting_Area_Name,
    SUM(Tract_Median_Apartment_Contract_Rent_per_Unit * PROPERTIES) / 
        SUM(PROPERTIES) AS Weighted_Avg_Rent
FROM Apartment_Market_Prices
WHERE PROPERTIES > 0
GROUP BY Community_Reporting_Area_Name;
```

### Density Analysis
```sql
SELECT 
    Tract_Name,
    PROPERTIES AS Property_Count,
    Shape_Area / 1000000 AS Area_Sq_Km,
    CAST(PROPERTIES / (Shape_Area / 1000000) AS DECIMAL(10,2)) AS Properties_per_Sq_Km
FROM Apartment_Market_Prices
WHERE PROPERTIES > 0
ORDER BY Properties_per_Sq_Km DESC;
```

---

## ⚠️ Important Notes

### Data Limitations
1. **Single Year Snapshot**: Dataset only contains 2001 data; limited temporal analysis
2. **Missing Values**: 3 tracts have zero values (likely non-residential)
3. **Exclusions**: Does not include single-family rentals, student housing, or senior living
4. **Median vs Mean**: Uses median (less affected by outliers) rather than average

### Calculation Assumptions
1. YoY calculations assume consistent methodology across years
2. Mixed-income counts may include properties with varying subsidy levels
3. Property counts may change as buildings are constructed/demolished

### Known Issues (Pre-Cleaning)
- ❌ Scientific notation errors in rent fields
- ❌ Incorrect YoY calculations
- ❌ Inconsistent category assignments
- ✅ All resolved in cleaned dataset

---

## 📚 Related Documentation
- [Cleaning Process](CLEANING_PROCESS.md) - How data quality issues were resolved
- [Methodology](METHODOLOGY.md) - Analysis techniques and business rules
- [Setup Guide](SETUP_GUIDE.md) - How to work with this dataset
- [Main README](../README.md) - Project overview

---

## 📞 Questions or Issues?

If you have questions about field definitions or discover data quality issues:
- 📧 Email: [acsqlworks@gmail.com]
- 🐛 [Report Issue](https://github.com/acsqlworks/Apartment_Market_Prices/issues)

---

**Document Version**: 1.0  
**Last Updated**: November 9, 2025  
**Maintained By**: acsqlworks  

**Review Status**: ✅ Complete
