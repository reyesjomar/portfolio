SELECT * 
FROM world_life_expenctancy.world_life_expectancy;

-- Identifying duplicate records based on Country and Year combinations to ensure data consistency.
SELECT Country, 
Year, 
CONCAT(Country, Year), 
COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;
-- This query detects duplicate entries in the world_life_expectancy dataset by grouping records by Country and Year. If a combination appears more than once, it's flagged as a duplicate using HAVING COUNT() > 1.

-- Identifying duplicate Country-Year records by assigning row numbers, then filtering to isolate the duplicates for cleanup.
SELECT *
FROM	(
	SELECT ROW_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1
;
-- Detect and isolate duplicate rows based on a combination of Country and Year, so that only the extra entries can be reviewed or deleted.

-- Removing duplicate records based on identical Country-Year combinations, retaining only the first occurrence.
DELETE FROM world_life_expectancy
WHERE
	Row_ID IN (
    SELECT Row_ID
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1
)
;
-- Clean the dataset by deleting duplicate rows identified through repeated Country and Year combinations. This query retains the first instance of each duplicate and deletes the rest to ensure data integrity.

-- Handling missing values in the Status column by filling or filtering as part of data cleaning.
SELECT *
FROM world_life_expectancy
WHERE Status = ''
;
-- Identified and addressed NULL values in the Status column to ensure consistency before performing analysis. This may include filling with a default value (e.g., "Unknown") or filtering out incomplete rows depending on context.

-- Exploring distinct non-empty values in the Status column to understand valid entries.
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;
-- Checked for all distinct, non-empty values in the Status column to understand what categories exist and prepare for data cleaning. This helps identify valid entries and spot inconsistencies (e.g., blank or unexpected values).

-- Identifying which countries are labeled as 'Developing' in the Status column.
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;
-- Retrieved all distinct countries classified as 'Developing' to analyze patterns or disparities in life expectancy across development status categories.

-- Updating the Status column to 'Developing' for countries consistently labeled as such.
UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
	FROM world_life_expectancy
	WHERE Status = 'Developing'
    )
;
-- Standardized the Status column by ensuring all records for countries previously labeled as 'Developing' are consistently updated. This is done using a subquery to target countries with at least one 'Developing' label and apply it across all their entries.

-- Workaround using self-join to fill missing Status values based on matching Country entries.
UPDATE world_life_expectancy AS w1
JOIN world_life_expectancy AS w2
	ON w1.Country = w2.Country
SET w1.Status = 'Developing'
WHERE w1.Status = ''
AND w2.Status <> ''
AND w2.Status = 'Developing'
;

-- Addressed missing Status values by performing a self-join on the Country column. This allowed me to update empty Status fields with 'Developing' where at least one matching entry for that country already had a non-null Developing status. This workaround was necessary due to limitations in the original subquery-based UPDATE.
SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America'
;

-- Filling in missing 'Developed' values by referencing other entries for the same country.
UPDATE world_life_expectancy AS w1
JOIN world_life_expectancy AS w2
	ON w1.Country = w2.Country
SET w1.Status = 'Developed'
WHERE w1.Status = ''
AND w2.Status <> ''
AND w2.Status = 'Developed'
;
-- Used a self-join to update blank Status fields to 'Developed' for countries that already have at least one entry labeled 'Developed'.
-- Identifying rows with missing values in the Life Expectancy column.
-- Queried all rows where the Life Expectancy field is empty to assess the extent of missing data. This step is essential before deciding on a data imputation or exclusion strategy to maintain the accuracy of the analysis.

SELECT *
FROM world_life_expectancy
WHERE `Life Expectancy` = ''
;

-- Reviewing Country, Year, and Life Expectancy values to identify and assess missing data.
-- Retrieved a focused view of the Country, Year, and Life Expectancy columns to manually inspect and verify missing or inconsistent entries. This helps inform how to handle nulls before applying any data cleaning strategy.

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

-- Using a triple self-join to impute missing life expectancy values by averaging the year before and after.
-- Imputed missing Life expectancy values using a triple self-join strategy. For any row with a missing value, I joined the dataset to itself twice—once on the previous year and once on the following year for the same country.

SELECT w1.Country, w1.Year, w1.`Life expectancy`, 
w2.Country, w2.Year, w2.`Life expectancy`,
w3.Country, w3.Year, w3.`Life expectancy`,
ROUND((w2.`Life expectancy` + w3.`Life expectancy`) / 2, 1)
FROM world_life_expectancy AS w1
JOIN world_life_expectancy AS w2
	ON w1.Country = w2.Country
    AND w1.Year = w2.Year - 1
JOIN world_life_expectancy AS w3
	ON w1.Country = w3.Country
    AND w1.Year = w3.Year + 1
WHERE w1.`Life expectancy` = ''
;

-- Updating missing Life Expectancy values by averaging the values from the previous and following years.
-- Performed an UPDATE using a triple self-join to fill in missing values in the Life expectancy column. For each missing entry, I averaged the Life expectancy of the previous and following year for the same country, then rounded the result to one decimal place.

UPDATE world_life_expectancy AS w1
JOIN world_life_expectancy AS w2
	ON w1.Country = w2.Country
    AND w1.Year = w2.Year - 1
JOIN world_life_expectancy AS w3
	ON w1.Country = w3.Country
    AND w1.Year = w3.Year + 1
SET w1.`Life expectancy` = ROUND((w2.`Life expectancy` + w3.`Life expectancy`) / 2, 1)
WHERE w1.`Life expectancy` = ''
;