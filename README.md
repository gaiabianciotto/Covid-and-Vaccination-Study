# Covid and Vaccination Study

### Overview
This project performs in-depth analysis and data cleaning of global COVID-19 and vaccination data, exploring the relationships between COVID-19 infection rates, vaccination rates, and mortality across countries and continents. By querying and transforming data from the **covid-data** and **covid-vaccinations** tables, the analysis identifies trends in infection and death rates, explores the effectiveness of vaccination rollouts, and examines the equity of vaccine distribution globally.

The project uses SQL queries to clean, join, and analyze data to gain insights into the global pandemic response.

### Key Features
- **Data Cleaning:** Handles missing or incorrect values (e.g., continent data).
- **COVID-19 Analysis:** Analyzes infection rates, total cases, deaths, and trends across locations and continents.
- **Vaccination Effectiveness:** Compares infection rates before and after mass vaccination rollouts.
- **Global Vaccination Insights:** Examines vaccination coverage, effectiveness, and equity between developed and developing countries.
- **Seasonality Trends:** Analyzes COVID-19 trends across seasons (e.g., higher rates in winter months).
- **Join Tables:** Merges datasets from COVID-19 infection and vaccination data to gain insights into the correlation between vaccination rates and infection rates.
### Data Sources
- **covid-data (4):** Contains COVID-19 statistics such as total cases, deaths, and population.
- **covid-vaccinations (4):** Contains vaccination data like the number of vaccinations administered.
### SQL Queries
### 1. Data Selection and Cleaning
**a. Selecting Data from COVID Dataset**
```sql
SELECT *  
FROM PortfolioProject..[covid-data (4)]
WHERE continent is not null
ORDER BY 3,4;
```
This query selects the relevant data from the COVID-19 dataset where the ```continent``` field is not null.

**b. Checking Data Types of Key Fields**
```sql
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid-data (4)'
AND COLUMN_NAME IN ('total_cases', 'population');
```
This code checks the data types of ```total_cases``` and ```population``` columns to identify them as varchar.

**c. Converting Varchar Data to Numeric**
```sql
ALTER TABLE PortfolioProject..[covid-data (4)]
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject..[covid-data (4)]
ALTER COLUMN total_deaths FLOAT;
```
These queries convert the ```total_cases``` and ```total_deaths``` columns from ```varchar``` to ```FLOAT```.

### 2. Death Rate Analysis
**a. Likelihood of Dying if You Contract COVID-19 (by Location)**
```sql
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_deaths = 0 OR total_deaths IS NULL THEN NULL  
        ELSE (total_deaths/total_cases) * 100 
    END AS DeathsPercentage
FROM PortfolioProject..[covid-data (4)]
WHERE location LIKE '%states%'
ORDER BY 1, 2;
```
This query calculates the percentage of deaths relative to total cases in the dataset.

**b. Fixing Missing Continent Data**
```sql
UPDATE PortfolioProject..[covid-data (4)]
SET continent = NULL
WHERE TRIM(continent) = '';
```
This script updates missing continent data in the dataset.

### 3. Population vs COVID-19 Data
**a. Percentage of People Who Got COVID (by Location)**
```sql
SELECT 
    Location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN population = 0 OR population IS NULL THEN NULL 
        ELSE (total_cases / population) * 100 
    END AS PercentagePopulationGotCovid
FROM PortfolioProject..[covid-data (4)]
WHERE location LIKE '%states%'
ORDER BY 1,2;
```
This query calculates the percentage of the population that has contracted COVID-19 by location.

### 4. Infection Rate Analysis
**a. Countries with Highest Infection Rate Compared to Population (by Location)**
```sql
SELECT 
    Location,  
    MAX(total_cases) AS HighestInfectionCount, 
    population, 
    MAX(total_cases) * 100.0 / population AS PercentagePopulationInfected
FROM PortfolioProject..[covid-data (4)]
WHERE continent is not null
GROUP BY Location, population  
ORDER BY PercentagePopulationInfected DESC;
```
This query identifies countries with the highest infection rates relative to population.

### 5. Global COVID-19 Study
**a. Global COVID-19 Cases and Deaths Percentage**
```sql
SELECT 
    date, 
    SUM(CAST(new_cases AS INT)) AS total_new_cases,
    SUM(CAST(new_deaths AS INT)) AS total_new_deaths,
    CASE 
        WHEN SUM(CAST(new_cases AS INT)) = 0 OR SUM(CAST(new_cases AS INT)) IS NULL THEN NULL 
        ELSE (SUM(CAST(new_deaths AS INT)) * 1.0) / SUM(CAST(new_cases AS INT)) * 100 
    END AS PercentagePopulationGotCovid
FROM PortfolioProject..[covid-data (4)]
GROUP BY date
ORDER BY 1,2;
```
This query calculates the global percentage of the population affected by COVID-19 on a daily basis.

### 6. Seasonal Trends & COVID-19
**a. Identifying Invalid Date Values**
```sql
SELECT DISTINCT date
FROM PortfolioProject..[covid-data (4)]
WHERE ISDATE(date) = 0;
```
This script checks for invalid date values in the dataset.

**b. Seasonality & COVID Trends (Monthly Data)**
```sql
SELECT 
    location, 
    MONTH(CAST(date AS DATE)) AS Month, 
    YEAR(CAST(date AS DATE)) AS Year,
    SUM(CAST(new_cases AS BIGINT)) AS MonthlyCases, 
    SUM(CAST(new_deaths AS BIGINT)) AS MonthlyDeaths
FROM PortfolioProject..[covid-data (4)]
WHERE continent IS NOT NULL
GROUP BY location, YEAR(CAST(date AS DATE)), MONTH(CAST(date AS DATE))
ORDER BY Year, Month;
```
This analysis tracks monthly cases and deaths by location to check for seasonality patterns.

### 7. Vaccination Data Analysis
**a. Merging COVID-19 Data with Vaccination Data**
```sql
SELECT *
FROM PortfolioProject..[covid-data (4)] AS cvdea
JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
  ON cvdea.continent = cvvac.continent
  AND cvdea.date = cvvac.date;
```
This query merges the COVID-19 dataset with the vaccination dataset.

**b. Vaccination Effectiveness (Pre/Post Rollout)**
```sql
SELECT 
    cvdea.location,
    MAX(CAST(total_vaccinations AS BIGINT)) AS TotalVaccinations, 
    population, 
    (MAX(CAST(total_vaccinations AS BIGINT)) * 100.0 / population) AS VaccinationRate
FROM PortfolioProject..[covid-data (4)] AS cvdea
JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
    ON cvdea.location = cvvac.location 
    AND cvdea.date = cvvac.date
WHERE cvdea.continent IS NOT NULL
GROUP BY cvdea.location, population
ORDER BY VaccinationRate DESC;
```
This query analyzes vaccination effectiveness by comparing the infection rate before and after mass vaccination rollouts.

### 8. Additional Analysis
**a. Vaccine Distribution Equity (Developed vs Developing Countries)**
```sql
SELECT 
    cvdea.continent, 
    cvdea.location, 
    MAX(CAST(cvvac.total_vaccinations AS BIGINT)) AS TotalVaccinations, 
    CAST(cvdea.population AS BIGINT) AS population, 
    (MAX(CAST(cvvac.total_vaccinations AS BIGINT)) * 100.0 / CAST(cvdea.population AS BIGINT)) AS VaccinationRate
FROM PortfolioProject..[covid-data (4)] AS cvdea
JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
    ON cvdea.location = cvvac.location 
    AND cvdea.date = cvvac.date
WHERE cvdea.continent IS NOT NULL
GROUP BY cvdea.continent, cvdea.location, cvdea.population
ORDER BY VaccinationRate ASC;
```
This analysis compares vaccination rates between developed and developing countries.

### Conclusion
The SQL scripts in this repository provide an in-depth analysis of the global COVID-19 pandemic, focusing on case trends, death rates, vaccination efforts, and seasonality. This study aims to offer insights into the relationship between COVID-19 cases, vaccination distribution, and population demographics.
This project is open-source and intended for educational purposes. Feel free to use and modify the queries as needed.
