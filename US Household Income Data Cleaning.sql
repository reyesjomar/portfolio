SELECT * 
FROM us_project.ushouseholdincome
;

SELECT * 
FROM us_project.ushouseholdincome_statistics
;

-- Renamed corrupted column header to 'id' for proper accessibility and analysis.
ALTER TABLE us_project.ushouseholdincome_statistics RENAME COLUMN `ï»¿id` TO `id`;
-- Corrected a corrupted column name (ï»¿id) in the ushouseholdincome_statistics table caused by improper encoding during CSV import. Renamed it to a clean and usable id using the ALTER TABLE ... RENAME COLUMN command.

SELECT COUNT(id)
FROM us_project.ushouseholdincome
;

SELECT COUNT(id)
FROM us_project.ushouseholdincome_statistics
;

-- Identifying duplicate rows based on repeated 'id' values using a subquery with ROW_NUMBER().
SELECT *
FROM (
SELECT row_id,
id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
FROM us_project.ushouseholdincome
) AS duplicates
WHERE row_num > 1
;
-- Created a subquery to detect duplicate entries in the ushouseholdincome table by assigning a row number to each record grouped by the id field.
-- Using the ROW_NUMBER() window function, I filtered for rows where row_num > 1, which isolates all but the first occurrence of each duplicate — a common data validation step before cleanup.

DELETE FROM ushouseholdincome
WHERE row_id IN (
SELECT row_id
FROM (
	SELECT row_id,
	id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_project.ushouseholdincome
	) AS duplicates
WHERE row_num > 1)
;


SELECT DISTINCT State_Name, COUNT(State_Name)
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 1
;

-- Correcting a misspelled state name from 'georia' to 'Georgia' in the State_Name column.
UPDATE us_project.ushouseholdincome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;
-- Fixed a data entry error by updating records where the state name was misspelled as 'georia', correcting it to 'Georgia'.

-- Standardizing capitalization by correcting 'alabama' to 'Alabama' in the State_Name column.
UPDATE us_project.ushouseholdincome
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;
-- Standardized the State_Name values by correcting inconsistent capitalization (e.g., 'alabama' → 'Alabama').

SELECT DISTINCT *
FROM ushouseholdincome
WHERE Place = ''
;

-- Correcting the 'Place' value to 'Autaugaville' for records with mismatched County and City information.
UPDATE ushouseholdincome
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;

SELECT Type, COUNT(Type)
FROM ushouseholdincome
GROUP BY Type
;

-- -- Standardizing the 'Type' column by changing 'Boroughs' to the singular form 'Borough'.
UPDATE ushouseholdincome
SET Type = 'Borough'
WHERE Type = 'Boroughs';

-- Identifying records with missing or zero land area (ALand) to assess data quality.
SELECT DISTINCT ALand
FROM ushouseholdincome
WHERE (ALand = 0 OR ALand = '' OR ALand IS NULL)
;
-- Queried distinct combinations of ALand and AWater where ALand is either 0, empty, or null. This helps identify incomplete or potentially inaccurate geographic data that may affect spatial or demographic analyses.

SELECT DISTINCT AWater
FROM ushouseholdincome
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
;