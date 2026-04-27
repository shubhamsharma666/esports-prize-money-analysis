# Esports Prize Money Analysis

## Overview
This project analyzes global esports prize money trends using Python, SQL Server, and Power BI. The goal was to understand how the esports market has grown over time, which games and genres dominate prize earnings, and whether the market is becoming more concentrated or more distributed across titles.

The project follows an end-to-end analytics workflow:
- Python for data inspection, cleaning, feature engineering, and exploratory analysis
- SQL Server for data modeling, ETL, and analytical querying
- Power BI for interactive dashboarding and storytelling

## Business Questions
This project was built to answer the following questions:

1. Which games generated the most esports prize money?
2. Which genres dominate the esports market?
3. How has prize money changed over time?
4. How concentrated is the esports market among the top games?
5. Has market concentration changed over time?

## Tools Used
- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- SQL Server
- Power BI
- CSV helper tables for concentration trend visuals
- Codex with SQL MCP tooling for query cross-validation during development

## Datasets
Two main datasets were used:

### 1. `GeneralEsportData.csv`
Game-level summary dataset containing:
- game name
- release year
- genre
- total earnings
- offline earnings
- percent offline
- total players
- total tournaments

### 2. `HistoricalEsportData.csv`
Time-series dataset containing:
- date
- game name
- earnings
- players
- tournaments

These two datasets were combined to support both high-level summary analysis and historical trend analysis.

## Workflow

### Python
Python was used first to understand and prepare the data:
- loaded raw CSV files
- inspected structure, data types, nulls, and duplicates
- converted dates into datetime format
- created `Year` and `Month` features
- validated the merge key between datasets
- merged both datasets into a master analysis table
- investigated missing values in `PercentOffline`
- exported cleaned datasets for downstream use

### SQL Server
SQL Server was used to build a structured analytics model:
- created the `esports_analysis` database
- created a star schema with dimensions and a fact table
- loaded cleaned data into staging tables
- populated dimensions and fact table
- wrote analysis queries for rankings, trends, and concentration metrics
- created a supporting SQL view for HHI used in Power BI

### Power BI
Power BI was used to create a 3-page interactive dashboard:
- Overview
- Game Analysis
- Concentration

## Data Model
A star schema was created in SQL Server using the following tables:

### Dimensions
- `dim_genre`
- `dim_game`
- `dim_date`

### Fact Table
- `fact_esports_earnings`

### Staging Tables
- `stg_general_esports`
- `stg_historical_esports`

This structure was chosen to reduce redundancy, support clean relationships, and make the model suitable for Power BI.

## Key Findings
- `Dota 2` is the dominant title by total prize money, accounting for roughly 19% of the market.
- `Multiplayer Online Battle Arena`, `First-Person Shooter`, and `Battle Royale` are the leading genres by total earnings.
- Esports prize money grew sharply after 2013, with especially strong expansion from 2015 onward.
- The top 5 games account for about half of total esports prize money.
- The top 10 games account for nearly two-thirds of total esports prize money.
- Earlier esports years were highly concentrated among a few games.
- In recent years, concentration has declined, suggesting the market has become more distributed across more titles.

## Power BI Dashboard Pages

### 1. Overview
Shows:
- market size KPIs
- total earnings by year
- top 10 games by total earnings
- total earnings by genre

### 2. Game Analysis
Shows:
- top 10 games by total players
- top 10 games by total tournaments
- game-level detail table
- additional participation and offline metrics

### 3. Concentration
Shows:
- top game share
- top 5 share
- top 10 share
- top 5 concentration trend over time
- HHI trend over time
- market share by top games

## SQL Files

### `sql/ddl/01_create_schema.sql`
Creates the database objects used in the project:
- dimensions
- fact table
- staging tables
- primary and foreign keys

### `sql/transformations/02_load_data.sql`
Loads and transforms the cleaned CSV data:
- inserts data into staging tables
- populates dimensions
- populates the fact table
- validates row counts and sample outputs

### `sql/analysis/03_analysis_queries.sql`
Contains the analytical SQL used for the project:
- top games by earnings
- genre earnings
- yearly earnings trend
- market share calculations
- top 5 and top 10 concentration
- yearly concentration trend
- `vw_hhi_by_year` view

## Files Used In Power BI
- `powerbi/esports_market_dashboard.pbix`
- `data/Processed/top5_share_by_year.csv`
- `data/Processed/hhi_by_year.csv`

## Reproducibility
To reproduce this project:

1. Open the notebook in `notebooks/01_data_inspection.ipynb`
2. Run the Python data inspection and cleaning steps
3. Use SQL Server to run:
   - `sql/ddl/01_create_schema.sql`
   - `sql/transformations/02_load_data.sql`
   - `sql/analysis/03_analysis_queries.sql`
4. Open `powerbi/esports_market_dashboard.pbix`
5. Refresh the Power BI model if needed

## Project Structure
```text
esports-prize-money-analysis/
|-- data/
|   |-- Raw/
|   `-- Processed/
|-- notebooks/
|-- powerbi/
|-- sql/
|   |-- analysis/
|   |-- ddl/
|   `-- transformations/
|-- .gitignore
|-- Readme.md
`-- requirements.txt
```

## Notes
- Raw and processed datasets are included to make the project easier to review and reproduce.
- Helper CSVs were used to support Power BI concentration visuals.
- The Power BI dashboard was built on top of the SQL data model and supporting analysis outputs.


