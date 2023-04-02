SELECT*
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent IS NOT NULL
order by 
	3,4

--Select*
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract Covid in Canada
SELECT
	Location, date, total_cases, total_deaths,
	CONVERT(decimal, total_deaths)/
	CONVERT(decimal, total_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE
	 Location LIKE '%Canada%'

ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population that got Covid
SELECT
	Location, date,  Population, total_cases,
	CONVERT(decimal, total_deaths)/
	Population*100 AS PercentPopulationInfected
FROM 
	PortfolioProject.dbo.CovidDeaths
--WHERE
--	 Location LIKE '%Canada%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
	Location, Population, MAX(total_cases) AS HighestInfectionCount, 
	MAX(CONVERT(decimal, total_deaths)/
	Population)*100 AS PercentPopulationInfected
FROM 
	PortfolioProject.dbo.CovidDeaths
--WHERE
--	 Location LIKE '%Canada%'
GROUP BY 
	Location, Population
ORDER BY 
	PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT
	Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM 
	PortfolioProject.dbo.CovidDeaths
--WHERE
--	 Location LIKE '%Canada%'
WHERE
	continent IS NOT NULL
GROUP BY 
	Location
ORDER BY 
	TotalDeathCount desc


-- Breaking Things Down By Continent

-- Showing continents with the highest death count

SELECT
	continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM 
	PortfolioProject.dbo.CovidDeaths
--WHERE
--	 Location LIKE '%Canada%'
WHERE
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	TotalDeathCount desc


-- Global Numbers

SELECT
	SUM(new_cases) AS total_cases, 
	SUM(cast(new_deaths as int)) AS total_deaths, 
	SUM(cast(new_deaths as int))/ NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE
	 continent IS NOT NULL
--GROUP BY
--	date
ORDER BY 
	1,2

	SELECT*
	FROM	PortfolioProject.dbo.CovidDeaths dea


-- Looking at Total Population vs Vaccinations

SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE
		dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY 2, 3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO 
	#PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT*,
 (RollingPeopleVaccinated/Population)*100
FROM 
	#PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE 
	View PercentPopulationVaccinated AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as decimal)) OVER (Partition by dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL


