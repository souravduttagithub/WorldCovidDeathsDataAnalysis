use sql_project;

SELECT * FROM  CovidDeaths;

select date, total_cases, new_cases, total_deaths, population_density
from CovidDeaths
ORDER BY 3, 4;




-- Looking at Calculate Total cases and Total Deaths
SELECT SUM(total_cases) as Total_Cases, SUM(total_deaths) AS Total_Deaths 
FROM CovidDeaths;


-- Looking at Total cases vs Total Deaths
SELECT location, date, total_cases, total_deaths,  (total_deaths/ total_cases)*100 as DeathsPercentage
FROM CovidDeaths;

-- Shows Number of People DeathsPercentage  in India
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as  DeathsPercentage
FROM CovidDeaths 
WHERE location LIKE '%India%'
ORDER BY 1, 2;                                               

-- Looking at Total Cases vs Population
-- Shows What Percentage of population got covid

SELECT location, date, population, total_cases,  (total_cases/ population)*100 as PercentPopulationInfected
FROM CovidDeaths 
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rate compare to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/ population)*100) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC;

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as DECIMAL)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC;


SELECT * FROM  CovidVaccinations;

-- Joing the CovidDeaths table and CovidVaccinations table

SELECT *
FROM CovidDeaths cd INNER JOIN CovidVaccinations cv
ON cd.location= cv.location AND cd.date= cv.date;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations as DECIMAL)) OVER (PARTITION BY cd.location ORDER BY cd.date, cd.location) AS
RollingPeopleVaccinated
FROM  CovidDeaths cd INNER JOIN CovidVaccinations cv
ON cd.iso_code= cv.iso_code AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3, 4;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopulationvsVaccinations (continent, location, date, population, new_vaccinations,
RollingPeopleVaccinated)
AS (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(new_vaccinations as DECIMAL))  OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS RollingPeopleVaccinated
FROM CovidDeaths cd INNER JOIN CovidVaccinations cv
ON cd.iso_code = cv.iso_code AND cd.date= cv.date
WHERE cd.continent IS NOT NULL

)
SELECT *, (RollingPeopleVaccinated/ population)*100
FROM PopulationvsVaccinations;


-- Using Temporary Table to perform Calculation on Partition By in previous query

CREATE TEMPORARY TABLE PercentPopulationVaccinated(
continent VARCHAR(200),
location VARCHAR(200),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);
INSERT INTO PercentPopulationVaccinated
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(new_vaccinations as DECIMAL))  OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS RollingPeopleVaccinated
FROM CovidDeaths cd INNER JOIN CovidVaccinations cv
ON cd.iso_code = cv.iso_code AND cd.date= cv.date
WHERE cd.continent IS NOT NULL
);
SELECT *, (RollingPeopleVaccinated/ population)*100
FROM PercentPopulationVaccinated;


CREATE VIEW  PercentPopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population_density, cv.new_vaccinations,
SUM(CAST(new_vaccinations AS DECIMAL)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date)
AS RollingPeopleVaccinated
FROM CovidDeaths cd INNER JOIN CovidVaccinations cv
ON cd.iso_code = cv.iso_code AND cd.date = cv.date
WHERE cd.continent IS NULL;

SELECT * FROM PercentPopulationVaccinated;

