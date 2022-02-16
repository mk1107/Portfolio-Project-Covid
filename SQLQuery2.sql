-- Created by Mohanish Kashiwar
-- Protfolio Project on Covid data

-- Queries used for Tableau Project

-- Global stats (Tableau Table 1)

SELECT SUM(CAST(new_cases AS decimal)) AS total_cases, SUM(CAST(new_deaths AS decimal)) AS total_deaths, 
	SUM(CAST(new_deaths AS decimal))/SUM(CAST(new_cases AS decimal))*100 AS DeathPercentage,
	(SELECT SUM(CAST(total_vaccinations AS decimal)) 
			FROM PortfolioProject..CovidVaccinations
			WHERE continent IS NOT NULL 
			AND total_vaccinations IN (
				SELECT MAX(CAST(total_vaccinations AS decimal))
				FROM PortfolioProject..CovidVaccinations
				WHERE continent IS NOT NULL 
				GROUP BY location		
			)
	) AS total_vaccinations
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL



-- Group wise death counts (Tableau Table 2) 
-- We take 'World', 'European Union', 'International', 'Upper middle income', 'High income', 
-- 'Lower middle income','Low income' out as they are not inluded in the previous queries to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS decimal)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 
					'High income', 'Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount desc



-- Location wise highest infection vs population (Tableau Table 3) 

SELECT Location, Population, MAX(CAST(total_cases AS decimal)) AS HighestInfectionCount, 
			Max((CAST(total_cases AS decimal)/CAST(population AS decimal)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc



-- Location wise highest infection vs population with date for its occurence (Tableau Table 4) .

SELECT Location, Population,CAST(date AS date) as date,  MAX(CAST(total_cases AS decimal)) AS HighestInfectionCount,  
				Max((CAST(total_cases AS decimal)/CAST(population AS decimal)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc


-- Group wise vaccination Status (Tableau Table 5) 
-- We take 'World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income',
-- 'Low income' out as they are not inluded in the previous queries to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(total_vaccinations AS decimal)) AS TotalVaccinationCount
FROM PortfolioProject..CovidVaccinations AS vac
WHERE continent IS NULL 
	AND total_vaccinations IN (
		SELECT MAX(CAST(total_vaccinations AS decimal))
		FROM PortfolioProject..CovidVaccinations
		WHERE continent IS NULL 
		GROUP BY location		
	)AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income',
							'High income', 'Lower middle income','Low income')
GROUP BY location	
ORDER BY TotalVaccinationCount desc



-- Location wise highest vaccination vs population (Tableau Table 6) 

SELECT dea.Location, dea.Population, MAX(CAST(vac.total_vaccinations AS decimal)) AS HighestVaccinationCount,  
		Max((CAST(total_vaccinations AS decimal)/CAST(population AS decimal)))*100 as PercentPopulationVaacinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
GROUP BY dea.Location, dea.Population
ORDER BY PercentPopulationVaacinated desc



-- Location wise highest vaccination vs population with date for its occurence (Tableau Table 7) .

SELECT dea.Location, dea.Population, CAST(dea.date AS date) as date, MAX(CAST(vac.total_vaccinations AS decimal)) AS HighestVaccinationCount,
		Max((CAST(total_vaccinations AS decimal)/CAST(population AS decimal)))*100 as PercentPopulationVaacinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
GROUP BY dea.Location, dea.Population, dea.date
ORDER BY PercentPopulationVaacinated desc

