SELECT *
FROM CovidDeaths;

--altered columns to float
ALTER TABLE CovidDeaths
ALTER COLUMN icu_patients FLOAT;

--altered column to date
ALTER TABLE CovidDeaths
ALTER COLUMN date DATE;

--updated columns with empty or 0 value to null
UPDATE CovidDeaths
SET continent = NULL
WHERE continent = '';

--Likelihood of death based on contracting covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%india%'
ORDER BY 1, 2 desc; 

--Percent of population getting covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM CovidDeaths
ORDER BY 1, 2; 

--Country with highest infection rate compared to population
SELECT location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/NULLIF(population,0)))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc; 

--Contries with highest death count
SELECT Location,  
	MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc; 

--Continent with highest death count
SELECT continent,  
	MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc; 

--Global numbers
SELECT date, 
	SUM(new_cases) AS TotalCases, 
	SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2; 



SELECT * 
FROM CovidVaccinations;

--Total Population vs Vaccination 
SELECT cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3;

--USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS
(
SELECT cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *, (PeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac

--Temp table
DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (PeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

--Views
CREATE View PercentPopulationVaccinated as
SELECT cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS PeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null 

