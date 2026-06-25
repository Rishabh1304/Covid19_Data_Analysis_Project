CREATE DATABASE Covid19_Analysis;
USE Covid19_Analysis;

SET SQL_SAFE_UPDATES = 0;
UPDATE covid19_data 
SET Date = STR_TO_DATE(Date, '%m/%d/%Y');
ALTER TABLE covid19_data 
MODIFY COLUMN Date DATE;
SET SQL_SAFE_UPDATES = 1;

-- GLOBAL COVID-19 TOTAL METRICS AND OUTCOME RATES
SELECT SUM(Confirmed) AS Total_Global_Cases,
	SUM(Deaths) AS Total_Global_Deaths,
    SUM(Recovered) AS Total_Global_Recovered,
    ROUND((SUM(Deaths) / SUM(Confirmed)) * 100, 2) AS Global_Death_Rate_Percentage,
    ROUND((SUM(Recovered) / SUM(Confirmed)) * 100, 2) AS Global_Recovery_Rate_Percentage
FROM covid19_data
WHERE Date = '2020-07-27';

-- TOP 10 COUNTRIES WITH MAXIMUM COVID-19 CONFIRMED CASES
SELECT Country,
	MAX(Confirmed) AS Total_Confirmed_Cases,
    MAX(Deaths) AS Total_Deaths
FROM covid19_data
WHERE Date = '2020-07-27'
GROUP BY Country
ORDER BY Total_Confirmed_Cases DESC
LIMIT 10;

-- MONTHLY GLOBAL TREND OF COVID-19 CASES AND DEATHS
SELECT MONTHNAME(Date) AS Month_Name,
	MONTH(Date) AS Month_Number,
    SUM(Confirmed) AS Total_Cases,
    SUM(Deaths) AS Total_Deaths
FROM covid19_data
GROUP BY Month_Name, Month_Number
ORDER BY Month_Number ASC;

-- TOP 5 COUNTRIES BY TOTAL COVID-19 TESTS AND POPULATION RATIO
SELECT Country_Region, 
    Population, 
    TotalTests,
    ROUND((TotalTests / Population) * 100, 2) AS Testing_Percentage_of_Population
FROM worldometer_data
WHERE Population IS NOT NULL AND TotalTests IS NOT NULL
ORDER BY TotalTests DESC
LIMIT 5;

-- COMPARING TOTAL CONFIRMED CASES WITH TOTAL TESTS USING INNER JOIN
SELECT c.Country AS Country_Name,
    MAX(c.Confirmed) AS Total_Confirmed_Cases,
    MAX(w.TotalTests) AS Total_Tests_Done,
    MAX(w.Population) AS Population,
    ROUND((MAX(c.Confirmed) / MAX(w.TotalTests)) * 100, 2) AS Positivity_Test_Ratio_Percentage
FROM covid19_data c
INNER JOIN worldometer_data w 
    ON c.Country = w.Country_Region
WHERE c.Date = '2020-07-27' 
  AND w.TotalTests IS NOT NULL
GROUP BY c.Country
ORDER BY Total_Confirmed_Cases DESC
LIMIT 10;

-- COVID-19 TOTAL DEATHS AND RECOVERY BY CONTINENT
SELECT Continent,
    SUM(TotalCases) AS Total_Cases,
    SUM(TotalDeaths) AS Total_Deaths,
    ROUND((SUM(TotalRecovered) / SUM(TotalCases)) * 100, 2) AS Recovery_Rate_Percentage
FROM worldometer_data
WHERE Continent IS NOT NULL AND Continent != ''
GROUP BY Continent
ORDER BY Total_Deaths DESC;

-- TOP 5 COUNTRIES WITH HIGHEST CRITICAL TO ACTIVE CASES RATIO
SELECT Country_Region AS Country_Name,
    ActiveCases,
    Serious_Critical,
    ROUND((Serious_Critical / ActiveCases) * 100, 2) AS Critical_To_Active_Percentage
FROM worldometer_data
WHERE ActiveCases IS NOT NULL 
  AND Serious_Critical IS NOT NULL 
  AND ActiveCases > 1000
ORDER BY Critical_To_Active_Percentage DESC
LIMIT 5;

-- TOP 5 COUNTRIES WITH HIGHEST DEATH RATE AND POPULATION
SELECT Country_Region AS Country_Name,
    TotalCases,
    TotalDeaths,
    Population,
    ROUND((TotalDeaths / TotalCases) * 100, 2) AS Case_Fatality_Rate_Percentage
FROM worldometer_data
WHERE TotalCases IS NOT NULL 
  AND TotalDeaths IS NOT NULL 
  AND TotalCases > 5000
ORDER BY Case_Fatality_Rate_Percentage DESC
LIMIT 5;