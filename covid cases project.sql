select *
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4


select *
from PortfolioProject..CovidVaccine
where continent is not null
order by 3,4

select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

--total cases vs total death
--shows likelihood of dying if you contract covid in your country
select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentagePopulationinfected
from PortfolioProject..CovidDeath
where location like '%canada%'
order by 1,2


--total cases vs the population

select location,population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationinfected
from PortfolioProject..CovidDeath
where continent is not null
--where location like '%canada%'
Group by location,Population
order by PercentagePopulationinfected desc



--showing countries with highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
--where location like '%canada%'
Group by location
order by totalDeathCount desc

--- let categorize by continent

select continent, MAX(cast(Total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
--where location like '%canada%'
Group by continent
order by totalDeathCount desc



--use global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
select *
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 