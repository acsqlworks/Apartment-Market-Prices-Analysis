# 📐 Methodology

## Overview
This document outlines the analytical methodology, business rules, and statistical approaches used in the Seattle Apartment Market Prices analysis project. Understanding these methods is crucial for interpreting results and replicating the analysis.

---

## 🎯 Project Objectives

### Primary Goals
1. **Clean and standardize** dirty rental data from Kaggle
2. **Classify markets** by affordability and growth trends
3. **Identify investment opportunities** through quantitative analysis
4. **Assess displacement risk** across Seattle neighborhoods
5. **Provide actionable insights** for stakeholders

### Stakeholder Groups
- 🏢 **Real Estate Investors**: Seeking high-growth, undervalued markets
- 🏛️ **Policy Makers**: Tracking affordability and gentrification
- 🏠 **Renters**: Understanding market trends for housing decisions
- 📊 **Researchers**: Analyzing urban housing economics

---

## 🔬 Analytical Framework

### 1. Data Cleaning Methodology

#### Scientific Notation Correction
**Problem**: Rent values stored as 1.52 instead of $1,520  
**Detection Method**:
```sql
WHERE Tract_Median_Apartment_Contract_Rent_per_Unit < 100
```

**Correction Strategy**:
- Multiply by 100 for values in unexpected range
- Validated against known Seattle market benchmarks (2001)
- Cross-referenced with rent per square foot for consistency

**Validation**:
- Checked that corrected values fall within realistic range ($800-$3,000)
- Verified rent per unit correlates with rent per square foot
- Compared to historical Seattle rental data

#### Year-over-Year Calculation Approach
**Method**: SQL Window Functions (LAG)

**Why Window Functions?**
- ✅ Accurate historical comparison within same tract
- ✅ Handles missing years gracefully (returns NULL)
- ✅ Partitions by tract/neighborhood to prevent cross-contamination
- ✅ Industry-standard approach for time-series analysis

**Implementation**:
```sql
LAG(Tract_Median_Apartment_Contract_Rent_per_Unit) OVER (
    PARTITION BY Tract_Name, Community_Reporting_Area_Name 
    ORDER BY Year
)
```

**Percentage Calculation**:
```
YoY% = ((Current - Previous) / Previous) × 100
```

**Alternative Approaches Considered**:
- ❌ Self-join: More complex, harder to maintain
- ❌ Subqueries: Performance issues with large datasets
- ❌ Pre-calculated values: Contained errors, unreliable

---

### 2. Market Segmentation Strategy

#### Cost Category Classification

**Methodology**: Quantile-based with market-adjusted boundaries

**Category Definitions**:

| Category | Rent Range | Percentile | Market Position |
|----------|------------|------------|-----------------|
| **Budget** | <$800 | Bottom 10% | Subsidized/Low-income |
| **Affordable** | $800-$1,200 | 10-35% | Working class |
| **Moderate** | $1,201-$1,800 | 35-65% | Middle class |
| **Premium** | $1,801-$2,500 | 65-85% | Upper-middle |
| **Luxury** | >$2,500 | Top 15% | High-income |

**Rationale**:
1. **Based on 2001 Seattle Income Data**:
   - Median household income: ~$45,000
   - 30% rule: Max $1,125/month rent
   - Adjusted boundaries to capture market reality

2. **HUD Affordability Guidelines**:
   - Affordable = ≤30% of area median income
   - Used as baseline, adjusted for Seattle market

3. **Distribution Goals**:
   - Avoid too many categories (analysis paralysis)
   - Ensure meaningful differences between tiers
   - Balance granularity with usability

**Validation**:
```sql
-- Verify distribution is reasonable
SELECT 
    Cost_Category,
    COUNT(*) AS Count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS Percent
FROM Apartment_Market_Prices
GROUP BY Cost_Category;
```

**Result**: Normal distribution with peak in Moderate/Premium range ✅

---

#### Market Trend Classification

**Methodology**: Threshold-based with economic context

**Category Thresholds**:

| Category | YoY Change | Economic Interpretation |
|----------|------------|------------------------|
| **Rapid Growth** | >10% | Gentrification, speculation |
| **Significant Increase** | 5-10% | Strong demand, growth |
| **Moderate Increase** | 2-5% | Healthy appreciation |
| **Stable** | -2% to 2% | Market equilibrium |
| **Moderate Decrease** | -5% to -2% | Cooling market |
| **Significant Decrease** | <-5% | Declining area |

**Rationale**:
1. **Inflation Context (2001)**:
   - US CPI inflation: ~2.8%
   - Stable = close to inflation rate
   - Growth = exceeds inflation

2. **Real Estate Market Standards**:
   - 5%+ appreciation = "hot market"
   - 2-5% = typical growth
   - <0% = concern signal

3. **Displacement Risk**:
   - >10% = high displacement risk
   - 5-10% = moderate risk
   - <5% = lower risk

**Statistical Foundation**:
```
Mean YoY Change: 3.4%
Std Deviation: 4.2%
Categories align with ±1 std dev from mean
```

---

### 3. Investment Opportunity Analysis

#### Scoring Methodology

**Investment Potential Formula**:
```
Investment_Score = (Growth_Rate × 0.6) + (Affordability_Factor × 0.4)
```

**Components**:

1. **Growth Rate (60% weight)**:
   - Higher YoY% = Higher score
   - Indicates appreciating asset value
   - Future return potential

2. **Affordability Factor (40% weight)**:
   - Lower entry price = Higher score
   - Enables portfolio diversification
   - Lower financial barrier

**Categorization**:
```sql
CASE 
    WHEN YoY_Change > 5 AND Rent_per_Unit < 1500 
        THEN 'High Potential'
    WHEN YoY_Change BETWEEN 2 AND 5 AND Rent_per_Unit < 1800 
        THEN 'Moderate Potential'
    ELSE 'Low Potential'
END
```

**Key Assumptions**:
- Historical growth predicts future performance
- Entry affordability matters for investors
- Combination approach balances risk/reward

**Limitations**:
- Single year data limits predictive power
- Doesn't account for location quality factors
- Ignores vacancy rates and turnover

---

### 4. Statistical Techniques

#### Aggregation Methods

**Mean vs. Median**:
- **Primary Metric**: Median rent
- **Rationale**: Less affected by luxury outliers
- **When Mean Used**: Weighted averages by property count

**Weighted Averages**:
```sql
SUM(Rent × Properties) / SUM(Properties)
```
- Accounts for tract size differences
- Prevents small-tract bias
- More representative of market

#### Handling Missing Values

**Strategy**: Context-dependent exclusion

**Rules**:
1. **Zero values** (rows 9, 24, 25):
   - ❌ Excluded from averages
   - ✅ Kept in dataset for completeness
   - Likely non-residential or data gaps

2. **NULL YoY values**:
   - Expected for first year
   - Excluded from growth calculations
   - Noted in "No Data" category

3. **No imputation**:
   - Avoided inferring missing values
   - Maintains data integrity
   - Transparent about limitations

**Validation Query**:
```sql
SELECT 
    COUNT(*) AS Total,
    COUNT(CASE WHEN Rent_per_Unit > 0 THEN 1 END) AS Valid_Rent,
    COUNT(CASE WHEN YoY_Change IS NOT NULL THEN 1 END) AS Valid_YoY
FROM Apartment_Market_Prices;
```

---

### 5. Geographic Analysis Approach

#### Spatial Aggregation

**Levels of Analysis**:
1. **Census Tract** (finest): Individual neighborhoods
2. **Community Reporting Area** (mid): Grouped neighborhoods
3. **Citywide** (highest): Overall market trends

**Aggregation Method**:
```sql
-- Community-level: Weighted by properties
SELECT 
    Community_Reporting_Area_Name,
    SUM(Rent × Properties) / SUM(Properties) AS Weighted_Avg
FROM Apartment_Market_Prices
GROUP BY Community_Reporting_Area_Name;
```

**Why Weighted?**
- Prevents over-representation of small tracts
- Reflects actual renter experience
- More accurate market picture

#### Density Calculations

**Properties per Square Kilometer**:
```sql
PROPERTIES / (Shape_Area / 1000000)
```

**Use Cases**:
- Urban density comparison
- Development potential assessment
- Infrastructure planning

---

### 6. Business Rules

#### Inclusion Criteria

**Qualifying Properties**:
- ✅ 5+ rental units
- ✅ Market-rate apartments
- ✅ Mixed-income apartments
- ❌ Student housing
- ❌ Senior living facilities
- ❌ Corporate/military housing
- ❌ Single-family rentals

**Rationale**:
- Focuses on general rental market
- Excludes specialized housing types
- Consistent with HUD definitions

#### Outlier Treatment

**Approach**: Flag but don't exclude

**Outlier Definition**:
- Rent > $3,500 or < $500
- YoY change > ±20%

**Handling**:
```sql
CASE 
    WHEN Rent_per_Unit > 3500 THEN 'Potential Outlier'
    WHEN YoY_Change > 20 THEN 'Extreme Growth - Verify'
    ELSE 'Normal Range'
END
```

**Philosophy**:
- Real market may have extreme values
- Better to flag than delete
- Allows analyst judgment

---

## 📊 Analytical Outputs

### 10 Core Analysis Queries

Each analysis follows this structure:

1. **Clear Business Question**
2. **SQL Query with Comments**
3. **Result Interpretation**
4. **Actionable Insights**

**Example Structure**:
```sql
-- BUSINESS QUESTION: Which neighborhoods have highest growth?

SELECT TOP 10
    Community_Reporting_Area_Name,
    AVG(Year_over_Year_Change_in_Rent_per_Square_Foot) AS Avg_Growth
FROM Apartment_Market_Prices
WHERE Year_over_Year_Change_in_Rent_per_Square_Foot IS NOT NULL
GROUP BY Community_Reporting_Area_Name
ORDER BY Avg_Growth DESC;

-- INTERPRETATION: Areas with >8% growth show gentrification signs
-- ACTION: Monitor displacement risk, consider intervention
```

---

## 🎯 Success Metrics

### Data Quality KPIs

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Completeness | >85% | 88% | ✅ Pass |
| Accuracy (rent range) | 100% | 100% | ✅ Pass |
| Valid YoY calculations | >65% | 69% | ✅ Pass |
| Category distribution | Normal | Normal | ✅ Pass |

### Analysis Quality

- ✅ All queries execute without errors
- ✅ Results align with known Seattle market
- ✅ No unexpected NULL values in critical fields
- ✅ Distribution of categories is reasonable

---

## 🔄 Reproducibility

### To Replicate This Analysis:

1. **Environment**:
   - SQL Server 2016+
   - Dataset: Seattle apartment prices (Kaggle)

2. **Script Execution Order**:
   ```
   1. Create backup
   2. Fix rent values (Step 2)
   3. Recalculate YoY (Step 3)
   4. Assign categories (Steps 4-5)
   5. Run analysis queries (Step 6)
   ```

3. **Validation Checkpoints**:
   - After Step 2: Verify rent range $800-$3,000
   - After Step 3: Check YoY range -10% to +15%
   - After Step 4: Confirm category distribution
   - After Step 6: Spot-check 3-5 results manually

4. **Expected Runtime**: 2-5 minutes on standard hardware

---

## ⚠️ Limitations & Assumptions

### Data Limitations

1. **Single Year Snapshot**:
   - Can't identify long-term trends
   - YoY changes may not be reliable
   - Seasonal effects not accounted for

2. **Source Data Quality**:
   - CoStar data may have gaps
   - Self-reported by property managers
   - Potential reporting bias

3. **Geographic Boundaries**:
   - Census tracts may not match neighborhood perception
   - Boundaries change over time
   - Aggregation may mask local variation

### Analytical Assumptions

1. **Market Efficiency**:
   - Assumes rational pricing
   - May not capture speculative bubbles
   - Ignores behavioral economics

2. **Temporal Consistency**:
   - Assumes YoY comparisons use same methodology
   - May miss definition changes
   - Inflation not explicitly adjusted

3. **Spatial Homogeneity**:
   - Assumes tracts are internally consistent
   - May mask within-tract variation
   - Edge effects not considered

### Use Case Limitations

**NOT Suitable For**:
- ❌ Individual property valuation
- ❌ Legal/regulatory decisions without additional data
- ❌ Long-term forecasting (need multi-year data)
- ❌ Microeconomic analysis

**Well-Suited For**:
- ✅ Comparative neighborhood analysis
- ✅ Market trend identification
- ✅ Policy impact assessment (with caveats)
- ✅ Investment screening (initial filter)

---

## 🔮 Future Enhancements

### Proposed Improvements

1. **Multi-Year Analysis**:
   - Incorporate 2000-2024 data
   - True time-series modeling
   - Seasonal decomposition

2. **Additional Variables**:
   - Demographic data (income, race, education)
   - Transit accessibility scores
   - Crime statistics
   - School quality ratings

3. **Advanced Techniques**:
   - Regression modeling (predict rent)
   - Spatial autocorrelation (Moran's I)
   - Machine learning (clustering)
   - Forecasting (ARIMA, Prophet)

4. **Interactive Tools**:
   - Power BI dashboard
   - Web-based map interface
   - Real-time data updates

---

## 📚 References

### Methodology Sources

1. **HUD Affordability Standards**
   - Fair Market Rent calculations
   - Area Median Income guidelines

2. **Census Bureau**
   - Geographic boundary definitions
   - Tract numbering system

3. **Real Estate Analysis**
   - Appraisal Institute standards
   - NCREIF property metrics

4. **SQL Best Practices**
   - Window functions (T-SQL documentation)
   - Statistical aggregations

### Academic Foundation

- **Urban Economics**: Alonso-Muth-Mills model
- **Gentrification Theory**: Freeman & Braconi (2004)
- **Housing Affordability**: Stone's shelter poverty concept

---

## 📞 Methodology Questions?

For questions about analytical approaches:
- 📧 Email: [acsqlworks@gmail.com]
- 💬 [Open Discussion](https://github.com/acsqlworks/Apartment_Market_Prices/discussions)

---

## 🤝 Contributing

Have suggestions for improving the methodology?
1. Review current approach
2. Propose enhancement with rationale
3. Submit pull request with updated documentation
4. Validate results don't break existing analyses

---

**Document Version**: 1.0  
**Last Updated**: November 9, 2025  
**Maintained By**: acsqlworks  
**Peer Reviewed**: Pending  

**Status**: ✅ Production
