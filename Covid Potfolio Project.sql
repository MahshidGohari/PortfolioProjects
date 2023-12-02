SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--shows what the percentage of people got covid

SELECT location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%iran%'
order by 1,2

--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%iran%'
group by location, population
order by 4 desc

--showing countries with highest death count per Population

SELECT location, MAX(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
--where location like '%iran%'
where continent is not null
group by location
order by 2 desc

--By Continent

SELECT location, MAX(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
--where location like '%iran%'
where continent is null
group by location
order by 2 desc


--Global Numbers

SELECT date, MAX(total_cases) as TotalCases ,MAX(cast(total_deaths as int)) as DeathCount, MAX(cast(total_deaths as int))/MAX(total_cases)*100 as DeathPercetage
from PortfolioProject..CovidDeaths
--where location like '%iran%'
where continent is not null
group by date
order by 4 desc


select *
from PortfolioProject..CovidVaccinations

--Looking at Total Population vs Vaccination

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
--,(PeopleVaccinated/population)*100 (the reason we make CTE)
FROM PortfolioProject..CovidVaccinations vac
join PortfolioProject.. CovidDeaths dea
	ON dea.date=vac.date
	and dea.location=vac.location
WHERE dea.continent is not null
ORDER BY 2,3



-- Create CTE

WITH PopvsVac (continent,location,date,population, new_vaccination, PeopleVaccinated)

as
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
join PortfolioProject.. CovidDeaths dea
	ON dea.date=vac.date
	and dea.location=vac.location
WHERE dea.continent is not null
)

SELECT *, (PeopleVaccinated/population)*100 AS Percentage
from PopvsVac
where location= 'Israel'

--SELECT  location , (MAX(PeopleVaccinated)/MAX(population))*100 AS Percentage
--FROM PopvsVac
--group by location
--order by 2 desc




-- Also we can create Temp Table


DROP TABLE IF EXISTS #PercantageVacPeople
CREATE TABLE #PercantageVacPeople
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)


INSERT INTO #PercantageVacPeople
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
join PortfolioProject.. CovidDeaths dea
	ON dea.date=vac.date
	and dea.location=vac.location
WHERE dea.continent is not null


SELECT *, (PeopleVaccinated/population)*100 AS Percentage
from #PercantageVacPeople


--Create view for vizualization

CREATE VIEW PercantagePopulationVaccinated as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
join PortfolioProject.. CovidDeaths dea
	ON dea.date=vac.date
	and dea.location=vac.location
WHERE dea.continent is not null