--Monthly accident distribution
SELECT
    EXTRACT(MONTH FROM date) AS month,
    COUNT(*) AS total_accidents
FROM nyc_collisions
GROUP BY month
ORDER BY month;

--Accident by month (% of total) 
SELECT
    EXTRACT(MONTH FROM date) AS month,
    COUNT(*) AS total_accidents,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_total
FROM nyc_collisions
GROUP BY month
ORDER BY month;

--Accident frequency by day of week and hour of day
--By day of week
SELECT
    EXTRACT(DOW FROM date) AS day_of_week,
    COUNT(*) AS total_accidents
FROM nyc_collisions
GROUP BY day_of_week
ORDER BY day_of_week;

--By hour of day
SELECT
    collision_hour,
    COUNT(*) AS total_accidents
FROM nyc_collisions
GROUP BY collision_hour
ORDER BY collision_hour;

--Accidents by day of week + hour of day
SELECT
    EXTRACT(DOW FROM date) AS day_of_week,
    collision_hour,
    COUNT(*) AS total_accidents
FROM nyc_collisions
GROUP BY day_of_week, collision_hour
ORDER BY total_accidents DESC;

--Street with the most accidents + % of total
--To find the street
SELECT
    street_name,
    COUNT(*) AS total_accidents
FROM nyc_collisions
WHERE street_name IS NOT NULL
GROUP BY street_name
ORDER BY total_accidents DESC
LIMIT 1;

--Street with the most accident
WITH street_counts AS (
    SELECT
        street_name,
        COUNT(*) AS total_accidents
    FROM nyc_collisions
    WHERE street_name IS NOT NULL
    GROUP BY street_name
)
SELECT
    street_name,
    total_accidents,
    ROUND(
        total_accidents * 100.0 / (SELECT COUNT(*) FROM nyc_collisions),
        2
    ) AS percent_of_total
FROM street_counts
ORDER BY total_accidents DESC
LIMIT 1;

--Most common contributing factor for all accidents
SELECT
    contributing_factor,
    COUNT(*) AS total_accidents
FROM nyc_collisions
WHERE contributing_factor IS NOT NULL
GROUP BY contributing_factor
ORDER BY total_accidents DESC
LIMIT 1;

--Contributing factor for Fatal accidents only
SELECT
    contributing_factor,
    COUNT(*) AS fatal_accidents
FROM nyc_collisions
WHERE persons_killed > 0
  AND contributing_factor IS NOT NULL
GROUP BY contributing_factor
ORDER BY fatal_accidents DESC
LIMIT 1;

--Boroughs with highest fatality rates
SELECT
    borough,
    SUM(persons_killed) AS total_killed,
    COUNT(*) AS total_collisions,
    ROUND(
        SUM(persons_killed) * 1.0 / COUNT(*),
        4
    ) AS fatality_rate
FROM nyc_collisions
GROUP BY borough
ORDER BY fatality_rate DESC;

--Road users fatalities
--Who is most at risk?
SELECT
    'Pedestrians' AS road_user,
    SUM(pedestrians_killed) AS deaths
FROM nyc_collisions
UNION ALL
SELECT
    'Cyclists',
    SUM(cyclists_killed)
FROM nyc_collisions
UNION ALL
SELECT
    'Motorists',
    SUM(motorists_killed)
FROM nyc_collisions;
