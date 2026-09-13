-- Resource 4: corrected MySQL 8 queries
USE ev_sales_db;

-- Question 1: unique makers in the 2-wheeler category
SELECT COUNT(DISTINCT maker) AS number_of_makers
FROM electric_vehicle_sales_by_makers
WHERE vehicle_category = '2-Wheelers';

-- Question 2: top three 2-wheeler makers in each of FY 2023 and FY 2024
WITH maker_sales AS (
    SELECT
        dd.fiscal_year,
        evm.maker,
        SUM(evm.electric_vehicles_sold) AS total_ev_sold
    FROM electric_vehicle_sales_by_makers AS evm
    JOIN dim_date AS dd
        ON evm.date = dd.date
    WHERE evm.vehicle_category = '2-Wheelers'
      AND dd.fiscal_year IN (2023, 2024)
    GROUP BY dd.fiscal_year, evm.maker
),
ranked_makers AS (
    SELECT
        fiscal_year,
        maker,
        total_ev_sold,
        ROW_NUMBER() OVER (
            PARTITION BY fiscal_year
            ORDER BY total_ev_sold DESC
        ) AS maker_rank
    FROM maker_sales
)
SELECT fiscal_year, maker, total_ev_sold
FROM ranked_makers
WHERE maker_rank <= 3
ORDER BY fiscal_year, maker_rank;

-- Question 3: average monthly total-vehicle sales in FY 2024
WITH monthly_sales AS (
    SELECT
        evs.date,
        SUM(evs.total_vehicles_sold) AS total_vehicle_sales
    FROM electric_vehicle_sales_by_state AS evs
    JOIN dim_date AS dd
        ON evs.date = dd.date
    WHERE dd.fiscal_year = 2024
    GROUP BY evs.date
)
SELECT ROUND(AVG(total_vehicle_sales), 0) AS avg_total_sales_per_month
FROM monthly_sales;

-- Question 4: five states with the highest combined EV penetration in FY 2024
SELECT
    evs.state,
    ROUND(
        100.0 * SUM(evs.electric_vehicles_sold)
        / NULLIF(SUM(evs.total_vehicles_sold), 0),
        2
    ) AS penetration_rate
FROM electric_vehicle_sales_by_state AS evs
JOIN dim_date AS dd
    ON evs.date = dd.date
WHERE dd.fiscal_year = 2024
  AND evs.vehicle_category IN ('2-Wheelers', '4-Wheelers')
GROUP BY evs.state
ORDER BY penetration_rate DESC
LIMIT 5;

-- Question 5: states with the highest and lowest total-vehicle sales in FY 2023
WITH state_sales AS (
    SELECT
        evs.state,
        SUM(evs.total_vehicles_sold) AS total_vehicle_sales
    FROM electric_vehicle_sales_by_state AS evs
    JOIN dim_date AS dd
        ON evs.date = dd.date
    WHERE dd.fiscal_year = 2023
    GROUP BY evs.state
)
SELECT
    state,
    total_vehicle_sales,
    CASE
        WHEN total_vehicle_sales = (SELECT MAX(total_vehicle_sales) FROM state_sales)
            THEN 'Highest'
        ELSE 'Lowest'
    END AS sales_level
FROM state_sales
WHERE total_vehicle_sales = (SELECT MAX(total_vehicle_sales) FROM state_sales)
   OR total_vehicle_sales = (SELECT MIN(total_vehicle_sales) FROM state_sales)
ORDER BY total_vehicle_sales DESC;

-- Question 6: peak and low calendar months for EV sales across FY 2022 to FY 2024
WITH monthly_ev_sales AS (
    SELECT
        MONTH(evs.date) AS month_number,
        MONTHNAME(evs.date) AS month_name,
        SUM(evs.electric_vehicles_sold) AS total_ev_sales
    FROM electric_vehicle_sales_by_state AS evs
    JOIN dim_date AS dd
        ON evs.date = dd.date
    WHERE dd.fiscal_year BETWEEN 2022 AND 2024
    GROUP BY MONTH(evs.date), MONTHNAME(evs.date)
),
season_extremes AS (
    SELECT
        month_number,
        month_name,
        total_ev_sales,
        CASE
            WHEN total_ev_sales = (SELECT MAX(total_ev_sales) FROM monthly_ev_sales)
                THEN 'Peak'
            ELSE 'Low'
        END AS season_type
    FROM monthly_ev_sales
    WHERE total_ev_sales = (SELECT MAX(total_ev_sales) FROM monthly_ev_sales)
       OR total_ev_sales = (SELECT MIN(total_ev_sales) FROM monthly_ev_sales)
)
SELECT month_name, total_ev_sales, season_type
FROM season_extremes
ORDER BY total_ev_sales DESC;

-- Question 7: FY 2022 to FY 2024 CAGR for the top four FY 2024 2-wheeler makers
WITH maker_year_sales AS (
    SELECT
        evm.maker,
        SUM(CASE WHEN dd.fiscal_year = 2022 THEN evm.electric_vehicles_sold ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN dd.fiscal_year = 2024 THEN evm.electric_vehicles_sold ELSE 0 END) AS sales_2024
    FROM electric_vehicle_sales_by_makers AS evm
    JOIN dim_date AS dd
        ON evm.date = dd.date
    WHERE evm.vehicle_category = '2-Wheelers'
      AND dd.fiscal_year IN (2022, 2024)
    GROUP BY evm.maker
),
top_four AS (
    SELECT maker, sales_2022, sales_2024
    FROM maker_year_sales
    ORDER BY sales_2024 DESC
    LIMIT 4
)
SELECT
    maker,
    sales_2022,
    sales_2024,
    ROUND(
        (POWER(sales_2024 * 1.0 / NULLIF(sales_2022, 0), 1.0 / 2) - 1) * 100,
        2
    ) AS cagr_percentage
FROM top_four
ORDER BY cagr_percentage DESC;

-- Question 8: FY 2024 state categories based on EV penetration
WITH state_penetration AS (
    SELECT
        evs.state,
        SUM(evs.electric_vehicles_sold) AS total_ev_sales,
        SUM(evs.total_vehicles_sold) AS total_vehicles_sold,
        100.0 * SUM(evs.electric_vehicles_sold)
            / NULLIF(SUM(evs.total_vehicles_sold), 0) AS penetration_rate
    FROM electric_vehicle_sales_by_state AS evs
    JOIN dim_date AS dd
        ON evs.date = dd.date
    WHERE dd.fiscal_year = 2024
    GROUP BY evs.state
)
SELECT
    state,
    total_ev_sales,
    total_vehicles_sold,
    ROUND(penetration_rate, 2) AS penetration_rate,
    CASE
        WHEN penetration_rate > 7 THEN 'Above 7%'
        WHEN penetration_rate > 5 THEN 'Above 5%'
        WHEN penetration_rate > 3 THEN 'Above 3%'
        WHEN penetration_rate > 1 THEN 'Above 1%'
        ELSE 'Below 1%'
    END AS penetration_category
FROM state_penetration
ORDER BY penetration_rate DESC, state;
