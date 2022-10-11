select * from
Portfolio_Project..CovidDeaths

select * from
Portfolio_Project..CovidVaccinations

--Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from
Portfolio_Project..CovidDeaths
where location like '%india'
order by 1,2

--Total Cases vs Population
select Location, date, Population, total_cases, (total_cases/Population)*100 as CasesPercentage
from
Portfolio_Project..CovidDeaths
where location like '%india'
order by 1,2

--Highest Infection
select Location, Population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/Population))*100 as InfectionPercentage
from
Portfolio_Project..CovidDeaths
Group by Location, Population
order by InfectionPercentage desc

--countries with highest death counts
select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
from
Portfolio_Project..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--by continent with highest death counts
select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from
Portfolio_Project..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- golbal
select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from
Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
from
Portfolio_Project..CovidDeaths dea
JOIN
Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
from
Portfolio_Project..CovidDeaths dea
JOIN
Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

--Temp table
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
from
Portfolio_Project..CovidDeaths dea
JOIN
Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

--Creating view to store data for later visualisation
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
from
Portfolio_Project..CovidDeaths dea
JOIN
Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated