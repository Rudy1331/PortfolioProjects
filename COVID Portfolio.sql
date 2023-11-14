Select *
From PortfolioProject..CovidDeaths
WHERE continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..covidDeaths
Where Location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of popultaion got Covid

Select location, date, Population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--Where Location like '%states%'
WHERE continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, 
(CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, MAX(Population)), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
--Where Location like '%states%'
WHERE continent is not null
GROUP BY Location, Population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population


-- LET'S BREAK THINGS DOWN BY CONTINENT



Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where Location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--Where Location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC




-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DP
FROM PortfolioProject..covidDeaths
--Where Location like '%states%'
Where continent is not null
GROUP BY Date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- CTE Variation
 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 AS
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
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
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
--Where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated