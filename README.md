# 🏢 Seattle Apartment Market Prices Analysis

[![Data Source](https://img.shields.io/badge/Data-Kaggle-20BEFF?style=flat&logo=kaggle)](https://www.kaggle.com)
[![SQL](https://img.shields.io/badge/SQL-Server-CC2927?style=flat&logo=microsoft-sql-server)](https://www.microsoft.com/sql-server)
[![Excel](https://img.shields.io/badge/Excel-Analysis-217346?style=flat&logo=microsoft-excel)](https://www.microsoft.com/excel)

> **Comprehensive analysis of apartment rental prices across Seattle census tracts, featuring data cleaning, trend analysis, and market insights.**

## 📊 Project Overview

This project analyzes **apartment market rent prices by census tract** in Seattle, providing displacement risk indicators and market classification based on rental trends. The dataset was sourced from Kaggle but required extensive cleaning and transformation to extract meaningful business insights.

### Key Features
- ✅ **Data Cleaning Pipeline** - Fixed scientific notation, missing values, and data type issues
- 📈 **Market Segmentation** - Classified neighborhoods into 5 cost categories (Budget to Luxury)
- 🚀 **Trend Analysis** - Identified fastest growing and declining rental markets
- 💡 **Investment Insights** - Highlighted high-potential investment opportunities
- 🏘️ **Community Analysis** - Evaluated 10+ community reporting areas

---

## 📁 Repository Structure

```
Apartment_Market_Prices/
│
├── data/
│   ├── raw/                          # Original Kaggle dataset (dirty)
│   └── cleaned/                      # Processed and cleaned data
│
├── sql/
│   └── AMP Analysis SQL.sql          # Complete data cleaning & analysis script
│
├── output/
│   ├── 1. MARKET OVERVIEW BY YEAR.csv
│   ├── 2. MOST EXPENSIVE COMMUNITIES.csv
│   ├── 3. MOST AFFORDABLE COMMUNITIES.csv
│   ├── 4. FASTEST GROWING MARKETS.csv
│   ├── 5. DECLINING RENT MARKETS.csv
│   ├── 6. MARKET SEGMENTATION BY COST.csv
│   ├── 7. YEAR-OVER-YEAR CHANGE DISTRIBUTION.csv
│   ├── 8. MIXED INCOME HOUSING IMPACT.csv
│   ├── 9. COMMUNITY-LEVEL PERFORMANCE.csv
│   └── 10. INVESTMENT OPPORTUNITIES.csv
│
├── documentation/
│   ├── DATA_DICTIONARY.md
│   ├── METHODOLOGY.md
│   └── CLEANING_PROCESS.md
│
└── README.md
```

---

## 🧹 Data Cleaning Process

### Issues Identified & Resolved

| Issue | Problem | Solution |
|-------|---------|----------|
| **Scientific Notation** | Rent values stored as 3.32 instead of $3320 | Multiplied by 1000 where values < 1000 |
| **Missing Values** | Zero values in critical fields | Flagged and excluded from averages |
| **Incorrect YoY Calculations** | Pre-calculated changes were inaccurate | Recalculated using LAG() window functions |
| **Inconsistent Categories** | Cost categories didn't match actual data | Created 5-tier classification system |
| **Data Type Issues** | GEOID losing leading zeros | Converted to string type |
| **Outliers** | Some rent values exceeded realistic ranges | Validated and capped extreme values |

### Transformation Steps

1. **Backup Creation** - Preserved original dataset
2. **Rent Value Fixes** - Corrected decimal place errors
3. **YoY Recalculation** - Used SQL window functions to compute accurate changes
4. **Category Assignment** - Applied business rules for cost and trend categories
5. **Validation** - Cross-checked results against known Seattle market data

---

## 📈 Key Insights

### 1. Market Overview
- **Average Rent Per Unit**: $1,477
- **Rent Range**: $916 - $2,895
- **Total Census Tracts Analyzed**: 26

### 2. Cost Distribution
| Category | Tracts | Avg Rent | % of Market |
|----------|--------|----------|-------------|
| Luxury | 5 | $2,640 | 19.2% |
| Premium | 8 | $1,915 | 30.8% |
| Moderate | 7 | $1,295 | 26.9% |
| Affordable | 4 | $1,005 | 15.4% |
| Budget | 2 | $825 | 7.7% |

### 3. Market Trends
- **🚀 Rapid Growth**: 15.4% of markets (>10% YoY increase)
- **📊 Stable Markets**: 46.2% of markets (-2% to +2% change)
- **📉 Declining**: 11.5% of markets (<-2% change)

### 4. Top Investment Opportunities
Tracts with **high growth** (>5% YoY) AND **affordable entry** (<$1,500):
- Fremont
- Green Lake
- Ravenna/Bryant
- Queen Anne

---

## 🛠️ Technologies Used

- **SQL Server** - Data cleaning, transformation, and analysis
- **Microsoft Excel** - Output formatting and visualization preparation
- **GitHub** - Version control and project documentation

---

## 💻 How to Use This Repository

### Prerequisites
- SQL Server 2016 or later
- Microsoft Excel 2016 or later
- Basic understanding of SQL and data analysis

### Steps to Reproduce

1. **Clone the repository**
   ```bash
   git clone https://github.com/acsqlworks/Apartment_Market_Prices.git
   cd Apartment_Market_Prices
   ```

2. **Load the raw data**
   - Import `data/raw/apartment_market_prices.csv` into SQL Server
   - Create table: `[dbo].[Apartment_Market_Prices]`

3. **Run the cleaning script**
   ```sql
   -- Execute the comprehensive SQL script
   -- File: sql/AMP Analysis SQL.sql
   ```

4. **Export results**
   - 10 analysis queries will generate Excel-ready output
   - Results saved in `output/` folder

---

## 📊 Sample Queries

### Find Most Expensive Neighborhoods
```sql
SELECT TOP 10
    Community_Reporting_Area_Name,
    AVG(Tract_Median_Apartment_Contract_Rent_per_Unit) AS Avg_Rent
FROM [dbo].[Apartment_Market_Prices]
WHERE Year = 2001
GROUP BY Community_Reporting_Area_Name
ORDER BY Avg_Rent DESC;
```

### Identify High-Growth Markets
```sql
SELECT 
    Tract_Name,
    Year_over_Year_Change_in_Rent_per_Square_Foot AS Growth_Rate
FROM [dbo].[Apartment_Market_Prices]
WHERE Year_over_Year_Change_in_Rent_per_Square_Foot > 10
ORDER BY Growth_Rate DESC;
```

---

## 📖 Data Dictionary

| Column Name | Description | Data Type |
|-------------|-------------|-----------|
| `OBJECTID` | Unique identifier | Integer |
| `GEOID` | Census geographic identifier | String |
| `Tract_Name` | Census tract name | String |
| `Community_Reporting_Area_Name` | Neighborhood name | String |
| `Tract_Median_Apartment_Contract_Rent_per_Unit` | Median monthly rent ($) | Decimal |
| `Tract_Median_Apartment_Contract_Rent_per_Square_Foot` | Rent per sq ft ($) | Decimal |
| `Year_over_Year_Change_in_Rent_per_Unit` | Dollar change from previous year | Decimal |
| `Cost_Category` | Budget/Affordable/Moderate/Premium/Luxury | String |
| `Mixed_Rate_or_Mixed_Income_Apartments_in_Tract` | Count of mixed-income units | Integer |

📄 **[Full Data Dictionary →](documentation/DATA_DICTIONARY.md)**

---

## 🎯 Business Applications

### For Real Estate Investors
- Identify undervalued markets with high growth potential
- Assess displacement risk across neighborhoods
- Compare rental yields by geographic area

### For Policy Makers
- Track affordability trends across Seattle
- Evaluate impact of mixed-income housing
- Monitor gentrification indicators

### For Renters & Residents
- Understand market rates in different neighborhoods
- Identify stable vs. rapidly changing areas
- Plan for potential rent increases

---

## 📚 Additional Resources

- **Data Source**: [Kaggle - Seattle Apartment Market Prices](https://www.kaggle.com)
- **Original Data Provider**: CoStar Group (via Seattle Office of Planning and Community Development)
- **SQL Documentation**: [Microsoft SQL Server Docs](https://docs.microsoft.com/sql)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Areas for Contribution
- Additional visualizations (Power BI, Tableau)
- Python/R statistical analysis
- Time series forecasting models
- Interactive dashboards

---

## 📝 License

This project is available under the MIT License. The original dataset is provided by CoStar Group via the City of Seattle and may have separate usage terms.

---

## 👤 Author

**Your Name**
- GitHub: [@acsqlworks](https://github.com/acsqlworks)
- LinkedIn: [Your LinkedIn Profile]
- Portfolio: [https://acsqlworks.github.io/portfolio]

---

## 🌟 Acknowledgments

- **City of Seattle** - Office of Planning and Community Development
- **CoStar Group** - Original data provider
- **Kaggle** - Dataset hosting and community

---

## 📊 Project Status

✅ **Completed** - Data cleaning and initial analysis complete  
🔄 **Ongoing** - Continuous updates as new data becomes available  
🎯 **Future Plans** - Predictive modeling and interactive dashboards

---

<div align="center">

**If you found this project helpful, please consider giving it a ⭐!**

[Report Bug](https://github.com/acsqlworks/Apartment_Market_Prices/issues) · [Request Feature](https://github.com/acsqlworks/Apartment_Market_Prices/issues)

</div>
