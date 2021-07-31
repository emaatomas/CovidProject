-- Tableu Data

-- Table 1 - Global Numbers
SELECT  
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentagePerDay
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL

--Table 2 - Total Deaths Per Continent
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount

-- Table 3 - Percent Population Infected Per Country
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Table 3 - Percent Population infected
SELECT Location, Population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC