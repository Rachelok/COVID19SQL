/*
Rachel Ok
COVID-19 Data Set from ourworldindata.org
May 10, 2022

*/

Select *
From [Portfolio Project]..CovidDeaths
where continent is not null      -- to prevent countries from being grouped as a continent
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

------------------------------------------------------------------------------------------------------------------------------------------------------------
--The first step is to select the data that is going to be utlilized for the project.
-- ordering the data by location and date
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2                                                                 

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the Total deaths vs Total cases (Percentage of deaths from cases reported)
-- The Death Rate shows the likelihood of death if you contracted COVID-19 in Canada
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From [Portfolio Project]..CovidDeaths
Where location like '%canada%'
order by 1,2       

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the Total cases vs Population
-- The Contraction Rate shows the percentage of the Canadian Population who contracted COVID-19 
Select Location, date, total_cases, Population, (total_deaths/Population)*100 as ContractionRate
From [Portfolio Project]..CovidDeaths
Where location like '%canada%'
order by 1,2

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the number of new cases daily in every country
-- Countries will be ordered by location and date
Select Location, Population, date, new_cases
From [Portfolio Project]..CovidDeaths
order by 1,2,3

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the contraction rate across all countries
-- Countries are going to be ordered by highest contraction rate to lowest contraction rate
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractionRate
From [Portfolio Project]..CovidDeaths
Group by Location, Population
order by ContractionRate desc

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the total death count from COVID-19 across all countries
-- Countries are going to be ordered by highest total death count to lowest total death count
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the total death count from COVID-19 across all continents
-- Continents are going to be ordered by highest total death count to lowest total death count
Select continent, (sum(cast(total_deaths as int))) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null AND
	date = '2022-05-06 00:00:00:000'
Group by continent
order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- We are going to examine the Total Hospital Patients in every country
-- Countries will be ordered from the highest number of total hospital patients to the lowest number of total hospital patients
Select location, sum(cast(hosp_patients as int)) as TotalHospitalPatients
From [Portfolio Project]..CovidDeaths
--where continent like '%north america%'
Group by Location 
order by TotalHospitalPatients desc

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Here I want to examine government policies where the stringency index represents the Government Response Stringency index: a composite measure
-- based on 9 response indicators including school closures, workplace closures, and travel bans, rescaled to a value from 0 to 100 (100 = strictest response)
Select dea.continent, dea.location, dea.date, stringency_index
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Group by dea.location, dea.continent, dea.date, stringency_index

------------------------------------------------------------------------------------------------------------------------------------------------------------


-- After analyzing countries, we are going to be taking a look at global numbers

-- Here we examine the total cases, total deaths, and death percentage from 2020 to 2022 over time
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
order by 1,2

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Here we examine the current total cases, total deaths as well as the death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Here we examine the percentage of population vaccinated
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

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Here we are going to create a temporary table 
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

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Here we are going to Create a View to store data for later visualizations
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
