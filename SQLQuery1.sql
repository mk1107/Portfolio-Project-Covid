-- Created by Mohanish Kashiwar
-- Protfolio Project on Covid data
-- To check if data is imported correctly in database

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;


-- Selecting data to be used 

SELECT location, CONVERT(DATE, date) AS date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null 
ORDER BY location, date


-- Total cases vs total deaths
-- Likelihood of dying due to covin in India

SELECT location, CONVERT(DATE, date) AS date, total_cases, total_deaths, (CONVERT(decimal, total_deaths)/CONVERT(decimal, total_cases))*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths 
WHERE location = 'India' AND continent IS NOT null 
ORDER BY 1,2


-- Total cases vs population
-- Precentage of population got covid in India

SELECT location, CONVERT(DATE, date) AS date, population, total_cases, (CONVERT(decimal, total_cases)/CONVERT(decimal, population))*100 AS CasePercentage 
FROM PortfolioProject..CovidDeaths 
WHERE location = 'India' AND continent IS NOT null 
ORDER BY 1,2


-- Countries with highest infection rate compaired to population

SELECT location, population, MAX(CONVERT(decimal, total_cases)) AS HighestInfectionCount, MAX(CONVERT(decimal, total_cases)/CONVERT(decimal, population))*100 AS HighestInfectionPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null 
GROUP BY location, population 
ORDER BY HighestInfectionPercentage desc


-- Countries wise highest death count

SELECT location, MAX(CONVERT(decimal, total_deaths)) AS HighestDeath 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null 
GROUP BY location 
ORDER BY HighestDeath desc


-- Countries with highest death count per population

SELECT location, population, MAX(CONVERT(decimal, total_deaths)) AS HighestDeathCount, MAX(CONVERT(decimal, total_deaths)/CONVERT(decimal,population))*100 AS HighestdeathPercentage 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null 
GROUP BY location, population 
ORDER BY HighestDeathPercentage desc


-- Groupwise wise highest death count

SELECT location, MAX(CONVERT(decimal, total_deaths)) AS HighestDeath 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS null 
GROUP BY location 
ORDER BY HighestDeath desc


-- Continent wise highest death count

SELECT continent, MAX(CONVERT(decimal, total_deaths)) AS HighestDeath 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null 
GROUP BY continent 
ORDER BY HighestDeath desc


-- Date wise Global Death precentage 

SELECT CONVERT(DATE, date) AS dat, SUM(CONVERT(decimal,new_cases)) AS total_cases, SUM(CONVERT(decimal,new_deaths)) AS total_deaths, (SUM(CONVERT(decimal,new_deaths))/SUM(CONVERT(decimal,new_cases)))*100 AS DeathPercent 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT null 
GROUP BY date 
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, CONVERT(DATE,dea.date) AS date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, CONVERT(DATE, dea.date) AS date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercent
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated