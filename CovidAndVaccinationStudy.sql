SELECT * 
FROM PortfolioProject..[covid-data (4)]
WHERE continent is not null -- DATASET ISSUE: when continent is null, then location is set as the continent, which is wrong
ORDER BY 3,4


--Check Data Type
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid-data (4)'
AND COLUMN_NAME IN ('total_cases', 'population');
--They are Varcher Data
--Convertion From Varcher Data to Numeric 
ALTER TABLE PortfolioProject..[covid-data (4)]
ALTER COLUMN total_cases FLOAT;

ALTER TABLE PortfolioProject..[covid-data (4)]
ALTER COLUMN total_deaths FLOAT;


-- Looking for  Total Cases vs Total Deaths
-- Results Show the Likelihood of Dying if you Contract Covid in your Country by Location
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


-- Results Show the Likelihood of Dying if you Contract Covid in your Country by Continent
--Are there Missing Continents
SELECT DISTINCT continent, location
FROM PortfolioProject..[covid-data (4)];

--DATASET ISSUE: When Continent is Null, then Location is Set as the Continent, which is Wrong
--Solution:
--step1
UPDATE PortfolioProject..[covid-data (4)]
SET continent = NULL
WHERE TRIM(continent) = '';
--step2
UPDATE PortfolioProject..[covid-data (4)]
SET 
    continent = location,
    location = NULL
WHERE continent IS NULL AND location IS NOT NULL;
--No more Missing Continent Data
SELECT DISTINCT continent, location
FROM PortfolioProject..[covid-data (4)];
-- Results Show the Likelihood of Dying if you Contract Covid in your Country by Continent
SELECT 
    continent, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN NULL 
        ELSE (total_deaths * 100.0 / total_cases) 
    END AS DeathsPercentage
FROM PortfolioProject..[covid-data (4)]
ORDER BY 1, 2;


--Convertion From Varcher Data to Numeric 
ALTER TABLE PortfolioProject..[covid-data (4)]
ALTER COLUMN population FLOAT;

-- Looking at the Total Cases vs Population by Location 
--% of people who got covid
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

-- Looking at the Total Cases vs Population by Continent
SELECT 
    continent, 
    date, 
    CAST(total_cases AS BIGINT) AS total_cases, 
    CAST(population AS BIGINT) AS population, 
    CASE 
        WHEN CAST(population AS BIGINT) = 0 OR population IS NULL THEN NULL  
        ELSE (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 
    END AS PercentagePopulationGotCovid
FROM PortfolioProject..[covid-data (4)]
ORDER BY 1,2;



-- Looking at Countries at the Highest Infection Rate compared to Population by Location
SELECT 
    Location,  
    MAX(total_cases) AS HighestInfectionCount, 
    population, 
    MAX(total_cases) * 100.0 / population AS PercentagePopulationInfected
FROM PortfolioProject..[covid-data (4)]
WHERE continent is not null
GROUP BY Location, population  
ORDER BY PercentagePopulationInfected DESC;

-- Looking at Countries at the Highest Infection Rate compared to Population by Continent
SELECT 
    continent,  
    MAX(total_cases) AS HighestInfectionCount, 
    SUM(CAST(population AS BIGINT)) AS TotalPopulation,  
    MAX(total_cases) * 100.0 / SUM(CAST(population AS BIGINT)) AS PercentagePopulationInfected
FROM PortfolioProject..[covid-data (4)]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentagePopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population by Location
SELECT 
    Location,  
    MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..[covid-data (4)]
WHERE continent is not null
GROUP BY Location  
ORDER BY TotalDeathCount DESC;

-- Showing Continents with Highest Death Count per Population
SELECT 
    continent,  
    MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..[covid-data (4)]
WHERE continent is not null
GROUP BY continent  
ORDER BY TotalDeathCount DESC;

-- Global Study
-- Percentage of Global Population Got Covid per day
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

-- Percentage of Global Population Got Covid
SELECT 
    SUM(CAST(new_cases AS BIGINT)) AS total_new_cases,
    SUM(CAST(new_deaths AS BIGINT)) AS total_new_deaths,
    CASE 
        WHEN SUM(CAST(new_cases AS BIGINT)) = 0 OR SUM(CAST(new_cases AS BIGINT)) IS NULL THEN NULL 
        ELSE (SUM(CAST(new_deaths AS BIGINT)) * 1.0) / SUM(CAST(new_cases AS BIGINT)) * 100 
    END AS PercentagePopulationGotCovid
FROM PortfolioProject..[covid-data (4)]
ORDER BY 1,2;

-- Seasonality & COVID Trends:check if COVID spiked during winter
--First Check for Invalid Date Values
SELECT DISTINCT date
FROM PortfolioProject..[covid-data (4)]
WHERE ISDATE(date) = 0;
-- Second Clean the Data
UPDATE PortfolioProject..[covid-data (4)]
SET date = NULL
WHERE ISDATE(date) = 0;

-- Let's Check for Seasonality & COVID Trends
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

-- Let's Check which Months had the Highest Rate of Cases per Year
WITH MonthlyCases AS (
    SELECT 
        location, 
        MONTH(CAST(date AS DATE)) AS Month, 
        YEAR(CAST(date AS DATE)) AS Year,
        SUM(CAST(new_cases AS BIGINT)) AS MonthlyCases,
        ROW_NUMBER() OVER (PARTITION BY YEAR(CAST(date AS DATE)) 
                           ORDER BY SUM(CAST(new_cases AS BIGINT)) DESC) AS CasesRank
    FROM PortfolioProject..[covid-data (4)]
    WHERE continent IS NOT NULL
    GROUP BY location, YEAR(CAST(date AS DATE)), MONTH(CAST(date AS DATE))
)
SELECT 
    location,
    Month,
    Year,
    MonthlyCases
FROM MonthlyCases
WHERE CasesRank = 1
ORDER BY Year, Month;

-- Let's Check which Months had the Highest Rate of Deaths per Year
WITH MonthlyDeaths AS (
    SELECT 
        location, 
        MONTH(CAST(date AS DATE)) AS Month, 
        YEAR(CAST(date AS DATE)) AS Year,
        SUM(CAST(new_deaths AS BIGINT)) AS MonthlyDeaths,
        ROW_NUMBER() OVER (PARTITION BY YEAR(CAST(date AS DATE)) 
                           ORDER BY SUM(CAST(new_deaths AS BIGINT)) DESC) AS DeathRank
    FROM PortfolioProject..[covid-data (4)]
    WHERE continent IS NOT NULL
    GROUP BY location, YEAR(CAST(date AS DATE)), MONTH(CAST(date AS DATE))
)
SELECT 
    location,
    Month,
    Year,
    MonthlyDeaths
FROM MonthlyDeaths
WHERE DeathRank = 1
ORDER BY Year, Month;





-- TABLE 2
SELECT * 
FROM PortfolioProject..[covid-vaccinations (4)]
ORDER BY 3,4 
-- Same issue as TABLE 1: When Continent is Null, then Location is Set as the Continent, which is Wrong
SELECT DISTINCT continent, location
FROM PortfolioProject..[covid-vaccinations (4)]
--Solution:
--step1
UPDATE PortfolioProject..[covid-vaccinations (4)]
SET continent = NULL
WHERE TRIM(continent) = '';
--step2
UPDATE PortfolioProject..[covid-vaccinations (4)]
SET 
    continent = location,
    location = NULL
WHERE continent IS NULL AND location IS NOT NULL;
--No more Missing Continent Data
SELECT DISTINCT continent, location
FROM PortfolioProject..[covid-vaccinations (4)];

-- JOIN TABLES
SELECT *
FROM PortfolioProject..[covid-data (4)] AS cvdea
JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
  ON cvdea.continent = cvvac.continent
  AND cvdea.date = cvvac.date

 --Vaccination Effectiveness Analysis: Compare Infection Rates Before and After Mass Vaccination Rollouts
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

-- Vaccine Distribution Equity:Compare the Vaccination Rate in Developed vs Developing Countries
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

--Global Vaccination Leaderboard
SELECT 
    cvdea.location,
    MAX(CAST(cvvac.total_vaccinations AS BIGINT)) AS TotalVaccinations, 
    CAST(cvdea.population AS BIGINT) AS Population, 
    (MAX(CAST(cvvac.total_vaccinations AS BIGINT)) * 100.0 / CAST(cvdea.population AS BIGINT)) AS VaccinationRate
FROM PortfolioProject..[covid-data (4)] AS cvdea
JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
    ON cvdea.location = cvvac.location 
    AND cvdea.date = cvvac.date
GROUP BY cvdea.location, cvdea.population 
ORDER BY VaccinationRate DESC;

--Location with Highest Vaccination Rate Per Continent
WITH RankedVaccinations AS (
    SELECT 
        cvdea.continent,
        cvdea.location,
        MAX(CAST(cvvac.total_vaccinations AS BIGINT)) AS TotalVaccinations, 
        CAST(cvdea.population AS BIGINT) AS Population, 
        (MAX(CAST(cvvac.total_vaccinations AS BIGINT)) * 100.0 / CAST(cvdea.population AS BIGINT)) AS VaccinationRate,
        ROW_NUMBER() OVER (PARTITION BY cvdea.continent ORDER BY (MAX(CAST(cvvac.total_vaccinations AS BIGINT)) * 100.0 / CAST(cvdea.population AS BIGINT)) DESC) AS Rank
    FROM PortfolioProject..[covid-data (4)] AS cvdea
    JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
        ON cvdea.location = cvvac.location 
        AND cvdea.date = cvvac.date
    GROUP BY cvdea.continent, cvdea.location, cvdea.population
)
SELECT 
    continent,
    location,
    TotalVaccinations,
    Population,
    VaccinationRate
FROM RankedVaccinations
WHERE Rank = 1
ORDER BY continent;

-- Looking at Total Population vs Vaccinations 
-- to do so I need to Restore Location from Continent: I Need to undo the Change to the Dataset in order to See the Different Locations
UPDATE PortfolioProject..[covid-data (4)]
SET location = continent
WHERE location IS NULL AND continent IS NOT NULL;
-- Looking at Total Population vs Vaccinations
-- USE CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPopulationVaccinated) AS
(
    SELECT 
        cvdea.continent, 
        cvdea.location, 
        cvdea.date, 
        CAST(cvdea.population AS BIGINT) AS population,  
        CAST(cvvac.new_vaccinations AS BIGINT) AS new_vaccinations,  
        SUM(CAST(cvvac.new_vaccinations AS BIGINT)) 
            OVER (PARTITION BY cvdea.location ORDER BY cvdea.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPopulationVaccinated
    FROM PortfolioProject..[covid-data (4)] AS cvdea
    JOIN PortfolioProject..[covid-vaccinations (4)] AS cvvac
        ON cvdea.location = cvvac.location 
        AND cvdea.date = cvvac.date
    WHERE cvdea.continent IS NOT NULL
)
SELECT 
    *, 
    CASE 
        WHEN population = 0 OR population IS NULL THEN 0 
        ELSE (RollingPopulationVaccinated * 100.0 / population)  
    END AS VaccinationPercentage
FROM PopvsVac;




