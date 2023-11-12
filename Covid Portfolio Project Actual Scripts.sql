select * from [PortfolioProject].[dbo].[CovidDeaths] order by 3,4;
--select * from [dbo].[CovidVaccinations] order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population 
from [dbo].[CovidDeaths]
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
order by 1,2;


-- Looking at total cases vs population
-- Shows what percentage of population got covid
select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from [dbo].[CovidDeaths]
--where location like '%states%'
order by 1,2;

-- Looking at Countries with highest infection Rate compated to Population
select Location, Population, Max(total_cases) as HighestInfectionCount,
Max(total_cases/Population)*100 as PercentPopulationInfected
from [dbo].[CovidDeaths] group by Location, Population order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population
select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
Group by Location order by TotalDeathCount desc;

-- Let's break things down by continent
select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
Group by continent order by TotalDeathCount desc;

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage From PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by date order by 1,2;

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage From PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
-- Group by date 
order by 1,2;

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null order by 2,3;

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac;

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

-- Create View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated;





























