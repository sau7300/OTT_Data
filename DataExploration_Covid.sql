/*
Portfolio project- SQL data exploration on Covid dataset
dataset source: https://ourworldindata.org/covid-deaths
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select the data that we will be using

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Cases vs Total Deaths
--(shows likelihood of dying if you contract covid in your country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' AND continent is not null
ORDER BY 1,2


--Total Cases vs Population
--(shows what percentage of population got Covid)

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CovidPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' AND continent is not null
ORDER BY 1,2


--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Countries with highest death rate compared to population

SELECT location, population, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX((cast(total_deaths as int)/population))*100 AS PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationDeaths DESC


--Death count by Continents
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

--Death percentage on each day
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) AS total_deaths, (SUM(cast(new_deaths as INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

--total deaths till now
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) AS total_deaths, (SUM(cast(new_deaths as INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1


--JOINING BOTH COVID DEATHS AND COVID VACCINATION TABLES

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


--total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Percentage of people fully vaccinated

SELECT dea.continent, dea.location, dea.population, MAX(vac.people_fully_vaccinated) AS FullyVaccinatedPopulation,
MAX(vac.people_fully_vaccinated/dea.population)*100 AS PercentageFullyVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location, dea.population
ORDER BY 2


--Showing rolling sum of new vaccination location wise

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationSum
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'India'
ORDER BY 2,3



--Showing cardiovascular death rate by location

SELECT dea.continent, dea.location, MAX(dea.population) AS Population, MAX(vac.cardiovasc_death_rate) AS CardiovascularDeathRate
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location
ORDER BY 2



--Showing percentage people vaccinated using CTE

WITH PopvsVac ( Continent, Location, Date, Population, New_vaccinations, RollingVaccinationSum)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationSum
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'India'
--ORDER BY 2,3
)

SELECT *, (RollingVaccinationSum/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac



--Using TEMP TABLE


CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationSum numeric,
)


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationSum
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'India'
--ORDER BY 2,3




--Creating a View to use data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinationSum
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'India'
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
