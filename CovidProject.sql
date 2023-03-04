Select *
From CovidProject.dbo.CovidDeaths
Where continent is not null
Order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject.dbo.CovidDeaths
Order by 1,2



--total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From CovidProject.dbo.CovidDeaths
Where location like '%iran%'
Order by 1,2 



--total cases vs population

Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From CovidProject.dbo.CovidDeaths
Where location like '%iran%'
Order by 1,2 



-- countries with highest infection rate vs population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From CovidProject.dbo.CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc




-- countries with highest death count per population

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc 



-- continents with highest death count

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


-- global numbers

Select date, SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage
From CovidProject.dbo.CovidDeaths
Where continent is not null
Group by date



-- global numbers without date

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage
From CovidProject.dbo.CovidDeaths
Where continent is not null



-- total population vs vaccination (CTE)

with popVSvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From CovidProject.dbo.CovidDeaths as dea
Join CovidProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) *100 as PercentVaccinatedPeople
From popVSvac



-- total population vs vaccination (temp table)

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From CovidProject.dbo.CovidDeaths as dea
Join CovidProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) *100 as PercentVaccinatedPeople
From #PercentPopulationVaccinated



-- creating view

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From CovidProject.dbo.CovidDeaths as dea
Join CovidProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated