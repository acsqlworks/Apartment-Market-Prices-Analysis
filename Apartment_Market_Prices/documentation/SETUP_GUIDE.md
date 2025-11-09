# 🚀 Quick Setup Guide

## Prerequisites

### Required Software
- ✅ **SQL Server 2016+** (Express, Standard, or Enterprise)
- ✅ **SQL Server Management Studio (SSMS)** 18.0 or later
- ✅ **Microsoft Excel 2016+** (or compatible spreadsheet software)
- ✅ **Git** (for cloning repository)

### Optional Tools
- 📊 Power BI Desktop (for advanced visualizations)
- 🐍 Python 3.8+ with pandas (for additional analysis)
- 📈 Tableau Public (for interactive dashboards)

---

## 📥 Installation Steps

### 1. Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/acsqlworks/Apartment_Market_Prices.git

# Or using SSH
git clone git@github.com:acsqlworks/Apartment_Market_Prices.git

# Navigate to project directory
cd Apartment_Market_Prices
```

### 2. Set Up SQL Server Database

**Option A: Create New Database**
```sql
-- Open SSMS and connect to your SQL Server instance
-- Run these commands:

CREATE DATABASE ApartmentMarketAnalysis;
GO

USE ApartmentMarketAnalysis;
GO
```

**Option B: Use Existing Database**
```sql
-- Just make sure you're connected to your target database
USE YourDatabaseName;
GO
```

### 3. Create the Table Structure

```sql
CREATE TABLE [dbo].[Apartment_Market_Prices] (
    [OBJECTID] INT PRIMARY KEY,
    [Year] INT,
    [GEOID] VARCHAR(20),
    [Tract_Label] VARCHAR(50),
    [Tract_Name] VARCHAR(100),
    [Community_Reporting_Area_Name] VARCHAR(100),
    [Community_Reporting_Area_ID] VARCHAR(50),
    [Tract_Median_Apartment_Contract_Rent_per_Square_Foot] DECIMAL(18,2),
    [Tract_Median_Apartment_Contract_Rent_per_Unit] DECIMAL(18,2),
    [Year_over_Year_Change_in_Rent_per_Square_Foot] DECIMAL(18,2),
    [Year_over_Year_Change_in_Rent_per_Unit] DECIMAL(18,2),
    [Cost_Category] VARCHAR(50),
    [Year_over_Year_Change_in_Rent_Category] VARCHAR(50),
    [Mixed_Rate_or_Mixed_Income_Apartments_in_Tract] INT,
    [PROPERTIES] INT,
    [Shape_Area] DECIMAL(18,2),
    [Shape_Length] DECIMAL(18,2)
);
```

### 4. Import Raw Data

**Method 1: Using SSMS Import Wizard**
1. Right-click on your database → Tasks → Import Data
2. Choose "Flat File Source"
3. Browse to `data/raw/apartment_market_prices.csv`
4. Map columns to the table created above
5. Click "Finish" to import

**Method 2: Using BULK INSERT**
```sql
BULK INSERT [dbo].[Apartment_Market_Prices]
FROM 'C:\Path\To\Your\data\raw\apartment_market_prices.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
```

### 5. Run Cleaning & Analysis Script

```sql
-- Open the SQL script file in SSMS
-- File location: sql/AMP Analysis SQL.sql

-- Execute the entire script (F5 or Ctrl+E)
-- This will:
--   1. Create backup
--   2. Clean data
--   3. Recalculate metrics
--   4. Generate all 10 analysis outputs
```

### 6. Export Results to Excel

**For each insight query:**
1. Run the specific query section
2. Right-click results → "Save Results As..."
3. Save to `output/` folder with appropriate name
4. Or copy results and paste into Excel

---

## 🔍 Verification Checklist

After setup, verify everything is working:

- [ ] Database created successfully
- [ ] Table structure matches specification
- [ ] Raw data imported (26 records)
- [ ] Backup table created
- [ ] Rent values corrected (no values < $100)
- [ ] YoY changes recalculated
- [ ] Cost categories assigned
- [ ] All 10 analysis queries run successfully
- [ ] Output files generated in Excel

---

## 🐛 Troubleshooting

### Issue: "Cannot find table 'Apartment_Market_Prices'"

**Solution**: Make sure you've created the table and imported data
```sql
-- Check if table exists
SELECT * FROM sys.tables WHERE name = 'Apartment_Market_Prices';

-- If not found, recreate using Step 3 above
```

### Issue: "Conversion failed when converting varchar to numeric"

**Solution**: Check your CSV file encoding and delimiters
```sql
-- Try viewing raw import first
SELECT TOP 10 * FROM [dbo].[Apartment_Market_Prices];

-- Look for any non-numeric characters in numeric columns
```

### Issue: "Rent values still appear incorrect"

**Solution**: Re-run the cleaning section of the script
```sql
-- Start from the backup
DROP TABLE [dbo].[Apartment_Market_Prices];

SELECT * INTO [dbo].[Apartment_Market_Prices]
FROM [dbo].[Apartment_Market_Prices_BACKUP];

-- Then re-run Steps 2-5 from the main script
```

### Issue: "LAG function not recognized"

**Solution**: You need SQL Server 2012 or later
```sql
-- Check your SQL Server version
SELECT @@VERSION;

-- If version is older, upgrade or use subqueries instead of LAG()
```

---

## 📂 File Organization Tips

### Recommended Folder Structure

```
Apartment_Market_Prices/
│
├── 📁 data/
│   ├── raw/
│   │   └── apartment_market_prices.csv      # Original Kaggle data
│   └── cleaned/
│       └── apartment_market_prices_clean.csv # Post-cleaning export
│
├── 📁 sql/
│   ├── AMP Analysis SQL.sql                 # Main cleaning & analysis
│   ├── 01_create_table.sql                  # Table structure only
│   └── 02_validation_queries.sql            # QA checks
│
├── 📁 output/
│   ├── 1. MARKET OVERVIEW BY YEAR.xlsx
│   ├── 2. MOST EXPENSIVE COMMUNITIES.xlsx
│   └── ... (all 10 analysis outputs)
│
├── 📁 documentation/
│   ├── DATA_DICTIONARY.md
│   ├── METHODOLOGY.md
│   ├── CLEANING_PROCESS.md
│   └── SETUP_GUIDE.md                       # This file
│
└── 📄 README.md
```

---

## 🎯 Next Steps

After successful setup:

1. **Explore the Data**
   - Review all 10 analysis outputs
   - Identify interesting patterns
   - Note any anomalies

2. **Customize Analysis**
   - Modify SQL queries for your specific needs
   - Add new metrics or categories
   - Create custom visualizations

3. **Share Your Findings**
   - Document insights in project wiki
   - Create visualizations in Power BI/Tableau
   - Present to stakeholders

4. **Extend the Project**
   - Add time-series data for trend analysis
   - Incorporate demographic data
   - Build predictive models

---

## 💡 Tips for Success

### SQL Best Practices
- ✅ Always create backups before modifying data
- ✅ Test queries on small samples first
- ✅ Use transactions for multi-step operations
- ✅ Comment your code for future reference
- ✅ Version control your SQL scripts

### Analysis Best Practices
- ✅ Validate data quality at each step
- ✅ Document assumptions and business rules
- ✅ Cross-check results against known benchmarks
- ✅ Save intermediate results for audit trail
- ✅ Keep raw data separate from cleaned data

### Git Best Practices
- ✅ Commit frequently with meaningful messages
- ✅ Don't commit large binary files (use `.gitignore`)
- ✅ Create branches for experimental changes
- ✅ Tag major versions (v1.0, v2.0, etc.)
- ✅ Write clear pull request descriptions

---

## 📞 Getting Help

### Resources
- 📖 [SQL Server Documentation](https://docs.microsoft.com/sql)
- 💬 [Stack Overflow - SQL Server Tag](https://stackoverflow.com/questions/tagged/sql-server)
- 🎓 [SQL Tutorial](https://www.w3schools.com/sql/)

### Project-Specific Help
- 🐛 [Report Issues](https://github.com/acsqlworks/Apartment_Market_Prices/issues)
- 💡 [Request Features](https://github.com/acsqlworks/Apartment_Market_Prices/issues/new)
- 📧 Contact: [acsqlworks@gmail.com]

---

## ✅ Setup Complete!

You're now ready to analyze Seattle apartment market data! 

**Recommended First Steps:**
1. Run the Market Overview query to understand the dataset
2. Review the Top 10 Most Expensive Communities
3. Identify Investment Opportunities using Query #10
4. Experiment with creating your own custom queries

**Happy Analyzing! 📊**

---

**Document Version**: 1.0  
**Last Updated**: November 9, 2025  
**Maintained By**: acsqlworks