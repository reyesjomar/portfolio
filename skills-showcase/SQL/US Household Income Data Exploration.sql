SELECT * 
FROM us_project.ushouseholdincome
;

SELECT * 
FROM us_project.ushouseholdincome_statistics
;

-- Explore the relationship between the state and the amount of land/water
SELECT State_Name, SUM(ALand), SUM(AWater) 
FROM us_project.ushouseholdincome
GROUP BY State_Name
ORDER BY 2 DESC
;

SELECT State_Name, SUM(ALand), SUM(AWater) 
FROM us_project.ushouseholdincome
GROUP BY State_Name
ORDER BY 3 DESC
;

-- TOP 10 Largest States by Land
SELECT State_Name, SUM(ALand), SUM(AWater) 
FROM us_project.ushouseholdincome
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;

-- Retrieving the top 10 U.S. states with the largest total water area.
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.ushouseholdincome
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;
-- Aggregated land (ALand) and water (AWater) areas for each U.S. state, then ranked them by total water area in descending order.

-- Joining income data with statistics to analyze mean and median income by state and county type.
SELECT u.State_Name, 
County, 
Type, 
`Primary`,
Mean,
Median
FROM us_project.ushouseholdincome AS u
INNER JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
;
-- Performed an inner join between the ushouseholdincome and ushouseholdincome_statistics tables using the id field.
-- Retrieved fields such as State_Name, County, Type, Primary (possibly indicating primary metropolitan area), along with Mean and Median income values.
-- Filtered out entries where Mean equals zero to ensure only valid income data is used, and grouped by State_Name to prepare for high-level comparison across states.


-- Identifying the top 5 states with the lowest average household income based on mean and median values.
SELECT u.State_Name, 
ROUND(AVG(Mean),1), 
ROUND(AVG(Median),1)
FROM us_project.ushouseholdincome AS u
INNER JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2
LIMIT 5
;

-- Identifying the top 5 states with the highest average household income based on mean and median values.
SELECT u.State_Name, 
ROUND(AVG(Mean),1), 
ROUND(AVG(Median),1)
FROM us_project.ushouseholdincome AS u
INNER JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 5
;

-- Identifying the top 10 states with the highest average median household income.
SELECT u.State_Name, 
ROUND(AVG(Mean),1), 
ROUND(AVG(Median),1)
FROM us_project.ushouseholdincome AS u
INNER JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3 DESC
LIMIT 10
;

-- Identifying the bottom 10 states with the lowest average median household income.
SELECT u.State_Name, 
ROUND(AVG(Mean),1), 
ROUND(AVG(Median),1)
FROM us_project.ushouseholdincome AS u
INNER JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3 ASC
LIMIT 10
;

-- Analyzing place types with over 100 entries, ranked by highest average mean income.
SELECT Type,
COUNT(Type),
ROUND(AVG(Mean),1), 
ROUND(AVG(Median),1)
FROM us_project.ushouseholdincome AS u
INNER JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY 1
HAVING COUNT(Type) > 100
ORDER BY 3 DESC
;

-- Investigating which states use the 'Community' classification; identified Puerto Rico as the primary contributor.
SELECT *
FROM ushouseholdincome
WHERE Type = 'Community'
;

-- Comparing average mean incomes by city across all states.
SELECT u.State_Name, City, ROUND(AVG(Mean),1)
FROM us_project.ushouseholdincome AS u
JOIN us_project.ushouseholdincome_statistics AS us
	ON u.id = us.id
GROUP BY u.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC
;