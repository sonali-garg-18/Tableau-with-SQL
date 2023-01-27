SELECT * FROM portfolio_project..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM portfolio_project..CovidVaccinations
--ORDER BY 3,4 (according to 3rd and 4th column)

-- select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolio_project..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--looking at total cases vs total deaths
--showing the likelihood of dying if you contact covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM portfolio_project..CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2


--looking at total cases vs population
--shows what percentage of people got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

--looking at countries with highest infection rate compared to population



SELECT location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY percentpopulationinfected desc

--showing the countries with highest death count per population

SELECT location, max(cast(total_deaths as int)) as totaldeathcount
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY totaldeathcount desc

--breaking things down by continents

SELECT location, max(cast(total_deaths as int)) as totaldeathcount
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY totaldeathcount desc

SELECT continent, max(cast(total_deaths as int)) as totaldeathcount
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc

-- showing continents with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as totaldeathcount
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc

-- global number that is death percentage across the world

SELECT  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--total cases across the world
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM portfolio_project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- using covid vaccine table

SELECT * FROM portfolio_project..CovidVaccinations

-- joining the two tables together
SELECT * 
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date


--looking at total population vs vaccinations

--use CTE
with popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER (partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac


-- temp table
DROP table if exists #percentpopulationvaccinated
CREATE table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER (partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #percentpopulationvaccinated

--creating view to store data for later visualisations
CREATE VIEW percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER (partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated






