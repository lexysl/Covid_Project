SELECT * FROM coviddeaths
SELECT * FROM covidvaccination

-- Select data that I want to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Australia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopualationInfected
FROM coviddeaths
-- WHERE location like '%states%'
-- WHERE location like '%kingdom%'
-- WHERE location like '%australia%'
ORDER BY 1,2

-- Looking at the highest countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionrate, MAX((total_cases/population))*100 AS PercentPopualationInfected
FROM coviddeaths
GROUP BY population, location
ORDER BY PercentPopualationInfected DESC

-- Showing Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as SIGNED)) as TotalDeathCount
FROM coviddeaths
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as SIGNED)) as TotalDeathCount
FROM coviddeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS CASES per DAY
SELECT *
FROM coviddeaths dea
JOIN covidvacination vac
	ON dea.location = vac.location
    AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations AS SIGNED)) OVER (Partition BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
    
-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as SIGNED)) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
-- ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM PopvsVAC

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(new_vaccinations as SIGNED)) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
ORDER BY 2,3

-- Creating View for store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(new_vaccinations as SIGNED)) OVER (Partition by dea.location ORDER BY dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
join covidvaccination vac
	on dea.location = vac.location
    and dea.date = vac.date
-- ORDER BY 2,3

Select * FROM PercentPopulationVaccinated
