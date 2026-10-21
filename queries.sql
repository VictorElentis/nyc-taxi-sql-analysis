-- NYC Taxi Trips: SQL Analysis (SQLite)
-- Data: raw_trips.csv (6,433 trips, March 2019).
-- To run: open DB Browser for SQLite -> File -> Import -> Table from CSV file -> raw_trips.csv
-- (name the table raw_trips), then run this file in the Execute SQL tab.

------------------------------------------------------------
-- 1. BUILD THE TABLES
------------------------------------------------------------
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS zones;

-- Lookup table: one row per pickup zone
CREATE TABLE zones AS
SELECT ROW_NUMBER() OVER (ORDER BY pickup_zone) AS zone_id,
       pickup_zone AS zone_name,
       MIN(pickup_borough) AS borough
FROM raw_trips
WHERE pickup_zone IS NOT NULL AND pickup_zone <> ''
GROUP BY pickup_zone;

-- Fact table: one row per trip, linked to zones by zone_id
CREATE TABLE trips AS
SELECT ROW_NUMBER() OVER () AS trip_id,
       r.pickup, r.dropoff, r.passengers, r.distance, r.fare, r.tip,
       r.tolls, r.total, r.color,
       NULLIF(r.payment, '') AS payment,
       z.zone_id AS pickup_zone_id
FROM raw_trips r
LEFT JOIN zones z ON z.zone_name = r.pickup_zone;

------------------------------------------------------------
-- 2. DATA QUALITY CHECK
------------------------------------------------------------
SELECT COUNT(*)                   AS total_trips,
       SUM(payment IS NULL)       AS missing_payment,
       SUM(pickup_zone_id IS NULL) AS missing_zone,
       SUM(distance = 0)          AS zero_distance,
       MIN(fare) AS min_fare, MAX(fare) AS max_fare
FROM trips;

------------------------------------------------------------
-- Q1. How do cash and credit card trips differ?
-- (Cash tips are not recorded, so tips only mean something for cards.)
------------------------------------------------------------
SELECT payment,
       COUNT(*)                AS trips,
       ROUND(AVG(fare), 2)     AS avg_fare,
       ROUND(AVG(tip), 2)      AS avg_tip,
       ROUND(AVG(distance), 2) AS avg_distance
FROM trips
WHERE payment IS NOT NULL
GROUP BY payment
ORDER BY trips DESC;

------------------------------------------------------------
-- Q2. Which pickup boroughs earn the most? (JOIN)
------------------------------------------------------------
SELECT z.borough,
       COUNT(*)               AS trips,
       ROUND(SUM(t.total), 0) AS revenue,
       ROUND(AVG(t.total), 2) AS avg_total
FROM trips t
JOIN zones z ON z.zone_id = t.pickup_zone_id
GROUP BY z.borough
ORDER BY revenue DESC;

------------------------------------------------------------
-- Q3a. Busiest hour of the day (strftime)
------------------------------------------------------------
SELECT CAST(strftime('%H', pickup) AS INTEGER) AS hour,
       COUNT(*)            AS trips,
       ROUND(AVG(fare), 2) AS avg_fare
FROM trips
GROUP BY hour
ORDER BY hour;

-- Q3b. Grouped into periods of the day (CASE)
SELECT CASE
         WHEN CAST(strftime('%H', pickup) AS INTEGER) BETWEEN 6  AND 9  THEN '1 Morning rush'
         WHEN CAST(strftime('%H', pickup) AS INTEGER) BETWEEN 10 AND 15 THEN '2 Midday'
         WHEN CAST(strftime('%H', pickup) AS INTEGER) BETWEEN 16 AND 19 THEN '3 Evening rush'
         ELSE '4 Night'
       END AS period,
       COUNT(*)            AS trips,
       ROUND(AVG(fare), 2) AS avg_fare
FROM trips
GROUP BY period
ORDER BY period;

------------------------------------------------------------
-- Q4. Zones with the highest tip percentage (CTE + HAVING)
-- Credit card trips only, zones with at least 20 trips.
------------------------------------------------------------
WITH card_trips AS (
    SELECT * FROM trips
    WHERE payment = 'credit card' AND fare > 0
)
SELECT z.zone_name, z.borough,
       COUNT(*) AS trips,
       ROUND(100.0 * SUM(c.tip) / SUM(c.fare), 1) AS tip_pct
FROM card_trips c
JOIN zones z ON z.zone_id = c.pickup_zone_id
GROUP BY z.zone_id
HAVING COUNT(*) >= 20
ORDER BY tip_pct DESC
LIMIT 10;

------------------------------------------------------------
-- Q5. Top 3 busiest zones in each borough (window function RANK)
------------------------------------------------------------
WITH zone_counts AS (
    SELECT z.borough, z.zone_name, COUNT(*) AS trips
    FROM trips t JOIN zones z ON z.zone_id = t.pickup_zone_id
    GROUP BY z.zone_id
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY borough ORDER BY trips DESC) AS rnk
    FROM zone_counts
)
SELECT borough, rnk, zone_name, trips
FROM ranked
WHERE rnk <= 3
ORDER BY borough, rnk;

------------------------------------------------------------
-- Q6. Daily revenue with running total and 7-day moving average
------------------------------------------------------------
WITH d AS (
    SELECT DATE(pickup) AS day, ROUND(SUM(total), 2) AS revenue
    FROM trips
    GROUP BY day
)
SELECT day, revenue,
       ROUND(SUM(revenue) OVER (ORDER BY day), 2) AS running_total,
       ROUND(AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7d
FROM d
ORDER BY day;

------------------------------------------------------------
-- MY OWN QUESTIONS (add yours here)
------------------------------------------------------------
-- Q7:
-- Q8:
-- Q9:
