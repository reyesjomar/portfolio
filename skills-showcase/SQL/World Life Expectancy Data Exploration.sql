SELECT *
FROM world_life_expectancy
;

-- Performing EDA to analyze life expectancy trends by country and over time; filtering out invalid 0 values.
SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 
AND MAX(`Life expectancy`) <> 0 
ORDER BY Life_Increase_15_Years DESC
;
-- Conducted exploratory data analysis (EDA) to evaluate how life expectancy has changed for each country over the dataset’s timeframe. By calculating the minimum and maximum life expectancy values per country and subtracting them, I measured the overall improvement in life expectancy.

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;
-- Exploring the relationship between GDP and Life Expectancy across countries and development status.

SELECT Country, 
ROUND(AVG(`Life expectancy`),1) as Life_Exp, 
ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;
-- Evaluated the correlation between average GDP and life expectancy for each country. Filtered out invalid entries (0 values) to ensure data quality. Sorting by GDP helps identify if higher GDP tends to correspond with higher life expectancy.

SELECT
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS HighGDPCount,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) AS HighGDPLifeExpectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS LowGDPCount,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) AS LowGDPLifeExpectancy
FROM world_life_expectancy
;
-- Segmented the dataset into high and low GDP groups using a threshold of 1500. Calculated both group sizes and their respective average life expectancies to explore whether wealthier nations have significantly better health outcomes.

SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;
-- Compared average life expectancy between ‘Developed’ and ‘Developing’ countries to highlight health disparities tied to economic development level.

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;
-- Quantified the number of countries in each development category and compared their average life expectancies. This supports broader regional or policy-level analysis.

-- Exploring the relationship between average BMI and Life Expectancy by country.
SELECT Country,
ROUND(AVG(`Life expectancy`),1) as Life_Exp, 
ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI ASC
;
-- Analyzed how Body Mass Index (BMI) correlates with life expectancy across countries. For each country, calculated the average BMI and life expectancy, excluding invalid entries (values of 0).

-- Calculating a rolling total of Adult Mortality by country over the years.
SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;
-- Calculated a rolling (cumulative) total of Adult Mortality for each country, ordered by year. This allows for trend analysis over time — showing how adult mortality accumulates annually within each country.
-- Using the SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) window function helps preserve historical progression while enabling advanced time-series insights