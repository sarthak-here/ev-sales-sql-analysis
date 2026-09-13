# EV Sales SQL Analysis

This project demonstrates how to debug and validate analytical SQL using an electric-vehicle sales database. It includes corrected MySQL 8 queries and an executed Jupyter Notebook that verifies the same calculations locally with SQLite.

## Questions answered

- Number of unique 2-wheeler manufacturers
- Top three 2-wheeler manufacturers in fiscal years 2023 and 2024
- Average monthly total-vehicle sales in fiscal year 2024
- Top five states by EV penetration in fiscal year 2024
- States with the highest and lowest vehicle sales in fiscal year 2023
- Peak and low EV-sales months across fiscal years 2022 to 2024
- Two-year CAGR for leading 2-wheeler manufacturers
- State classification by EV penetration rate

## Files

- `corrected_queries.sql`: corrected, submission-ready MySQL 8 queries
- `ev_sales_sql_analysis.ipynb`: executable validation notebook
- `data/README.md`: instructions for adding the local database dump

## Run locally

1. Place the source dump at `data/ev_sales_db.sql`.
2. Install Python, pandas, and Jupyter.
3. Open `ev_sales_sql_analysis.ipynb`.
4. Run all cells.

The notebook loads only the three required tables into an in-memory SQLite database. The `.sql` file contains the corresponding MySQL 8 queries.

## Selected results

- The data contains 16 distinct 2-wheeler manufacturers.
- OLA Electric ranked first in both fiscal year 2023 and fiscal year 2024.
- Average monthly total-vehicle sales in fiscal year 2024 were 1,764,771.
- Goa had the highest combined EV penetration rate in fiscal year 2024 at 13.75%.
- March was the peak EV-sales month and June was the lowest across the analyzed period.

## Privacy

The source database dump and original assignment files are excluded from version control. This repository contains query logic and aggregate analytical outputs only.
