# NYC Taxi Trips: SQL Analysis

Which NYC taxi trips make the most money, and when and where does demand peak? This project answers six business questions about 6,400 taxi trips using SQL only.

## Data
The `taxis` dataset from seaborn: 6,433 NYC taxi trips from March 2019, with pickup and dropoff times, distance, fare, tip, payment type, and pickup and dropoff zones.

## Approach
- Loaded the data into a SQLite database and split it into a `trips` table and a `zones` lookup table (194 zones), so queries could use JOINs
- Checked data quality: 44 trips missing payment type, 26 missing pickup zone, 51 with zero distance
- Wrote every analysis step as a SQL query, run from Python with pandas only used to display results and draw charts

## SQL skills used
- Aggregation: `GROUP BY`, `HAVING`, `ORDER BY`
- Conditional logic: `CASE WHEN`
- Date handling: `strftime`
- `JOIN`s across tables
- CTEs (`WITH` clauses)
- Window functions: `RANK() OVER (PARTITION BY ...)`, running totals, and a 7-day moving average

## Key findings
- Credit card trips were longer and pricier than cash trips ($13.69 vs $11.59 average fare). Cash tips aren't recorded, so tip data covers credit card only
- Manhattan earned the most in total ($87.8k), but Queens had the highest average trip total ($31.66 vs $16.67) because of airport trips from JFK and LaGuardia
- Demand peaks in the evening (6 pm is the busiest hour with 417 trips), while average fare stays roughly the same through the day
- The highest tip percentages (about 25 to 28%) were in Manhattan neighbourhoods like Greenwich Village and the Upper East Side

## How to run
Open `nyc_taxi_sql_analysis.ipynb` in Google Colab and select Runtime → Run all. No downloads needed, since the data loads through seaborn.

## Limitations
The data covers one month and a small sample of trips, so zone rankings outside Manhattan are noisy. Cash tips are missing.

## Next steps
Weekday vs weekend demand, fare per mile by distance, and testing whether the airport premium holds on a larger dataset.

## My own questions
*(Add the three questions you wrote in section 9 and what you found.)*
