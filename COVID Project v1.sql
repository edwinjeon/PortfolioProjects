--Select *
--From PortfolioProject..CovidDeaths
--ORDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--ORDER BY 3,4



-- Select Data that we are going to use

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER By 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood dying if you contract COVID in your country

Select Location, Date, total_cases, total_deaths, (Total_Deaths/Total_cases) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'south korea' AND continent IS NOT NULL
ORDER By 1,2



-- looking at Total Cases vs Population
-- show what percentage of population got COVID

Select location, Date, total_cases, population, (total_cases/population) * 100 AS InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like 'south korea' AND continent is NOT NULL
ORDER By 1,2



-- looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, 
	max((total_cases/population)) *100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
GROUP by location, population
ORDER By 4 DESC



-- showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
GROUP by location
ORDER By TotalDeathCount DESC



-- breaking down things by continent

-- #1
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NULL
GROUP by location
ORDER By TotalDeathCount DESC

-- #2
--Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where continent IS NOT NULL
--GROUP by continent
--ORDER By TotalDeathCount DESC



-- global numbers

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths
	, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
--Group by date
ORDER By 1,2



-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Order by inside OVER = running total, accumulative
	, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location Order by dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3



-- USE CTE!

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Order by inside OVER = running total, accumulative
	, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location Order by dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population) *100 
From PopvsVac



-- Using Temp Tables

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Order by inside OVER = running total, accumulative
	, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location Order by dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) *100 
From #PercentPopulationVaccinated



-- Creating View to store data
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Order by inside OVER = running total, accumulative
	, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location Order by dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated