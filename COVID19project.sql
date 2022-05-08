Select *
From [Portfolio Project]..CovidDeaths
where continent is not null      -- to prevent countries from being grouped as a continent
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

--The first step is to select the data that is going to be utlilized for the project.
-- ordering the data by location and date
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2                                                                 

-- We are going to examine the Total deaths vs Total cases (Percentage of deaths from cases reported)
-- The Death rate shows the likelihood of death if you contracted COVID-19 in Canada
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From [Portfolio Project]..CovidDeaths
Where location like '%canada%'
order by 1,2       

-- Looking at Total cases vs Population
-- The contraction rate shows the percentage of the Canadian Population who contracted COVID-19 
Select Location, date, total_cases, Population, (total_deaths/Population)*100 as ContractionRate
From [Portfolio Project]..CovidDeaths
Where location like '%canada%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractionRate
From [Portfolio Project]..CovidDeaths
Group by Location, Population
order by ContractionRate desc

-- Looking at countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Looking at continents with total death count per population
Select continent, sum(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers 

-- total cases, total deaths, and death percentage (historical data)
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- The total cases, deaths, death percentage globally
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at total population vs vaccinations per day
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
