SELECT * 
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT * 
--FROM CovidProject..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, Population 
FROM CovidProject..CovidDeaths
ORDER BY 1, 2

-- Looking  at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Location Like '%Argentina%'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases Vs Population
-- Shows what porcentage of Population got covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS CovidPopulationPercentage
FROM CovidProject..CovidDeaths
--WHERE Location Like '%Argentina%'
ORDER BY 1, 2

-- looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS HighestCovidPopulationPercentage
FROM CovidProject..CovidDeaths
GROUP BY Location, Population
ORDER BY HighestCovidPopulationPercentage DESC

-- Showing Countries with  highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS HighestDeathsCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathsCount DESC

--LET'S BREAK  THINS DOWN  BY CONTINENT
-- Showing Continents with  highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathsCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathsCount DESC

-- GLOBAL NUMBERS
SELECT 
	date, 
	SUM(new_cases) AS WorldCasesPerDay, 
	SUM(CAST(new_deaths AS INT)) AS WorldDeathsPerDay, 
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentagePerDay
FROM CovidProject..CovidDeaths
--WHERE Location Like '%Argentina%'
WHERE continent IS NOT NULL
ORDER BY date


-- looking at Total Population Vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinations,
--	(rolling_people_vaccinations/dea.population)*100
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Use CTE

WITH PopVsVac (Continent, Location, Date, Population, News_Vaccinations, RollingPeopleVaccinations)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinations
	FROM CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinations/Population)*100 AS Percentage
FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF EXIST #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vacinations NUMERIC,
	RollingPeopleVaccinations NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinations
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinations/Population)*100 AS Percentage
FROM #PercentPopulationVaccinated

-- CREATED VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinations
	FROM CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

SELECT * FROM dbo.PercentPopulationVaccinated