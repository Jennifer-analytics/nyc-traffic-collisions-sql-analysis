--Row count
SELECT COUNT(*) FROM nyc_collisions;

--Checking for Nulls in key columns
SELECT
  COUNT(*) FILTER (WHERE borough IS NULL) AS missing_borough,
  COUNT(*) FILTER (WHERE date IS NULL) AS missing_date,
  COUNT(*) FILTER (WHERE time IS NULL) AS missing_time,
  COUNT(*) FILTER (WHERE persons_injured IS NULL) AS missing_injured,
  COUNT(*) FILTER (WHERE persons_killed IS NULL) AS missing_killed
FROM nyc_collisions;

--Replacing NULL injury/fatality values with 0
--Standardize injury and fatality fields to ensure accurate aggregations
UPDATE nyc_collisions
SET 
  persons_injured = COALESCE(persons_injured, 0),
  persons_killed = COALESCE(persons_killed, 0),
  pedestrians_injured = COALESCE(pedestrians_injured, 0),
  pedestrians_killed = COALESCE(pedestrians_killed, 0),
  cyclists_injured = COALESCE(cyclists_injured, 0),
  cyclists_killed = COALESCE(cyclists_killed, 0),
  motorists_injured = COALESCE(motorists_injured, 0),
  motorists_killed = COALESCE(motorists_killed, 0);

SELECT borough, COUNT(*)
FROM nyc_collisions
GROUP BY borough
ORDER BY COUNT(*) DESC;

--Standardize missing borough values
UPDATE nyc_collisions
SET borough = 'Unknown'
WHERE borough IS NULL OR borough = '';

--Create helper fields
--Extract hour from time
ALTER TABLE nyc_collisions
ADD COLUMN collision_hour INT;

UPDATE nyc_collisions
SET collision_hour = EXTRACT(HOUR FROM time);

--Collision severity category
ALTER TABLE nyc_collisions
ADD COLUMN severity VARCHAR(20);

UPDATE nyc_collisions
SET severity =
  CASE
    WHEN persons_killed > 0 THEN 'Fatal'
    WHEN persons_injured > 0 THEN 'Injury'
    ELSE 'Property Damage'
  END;