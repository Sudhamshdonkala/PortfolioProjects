select*
from PortfolioProject_New..CovidDeaths
where continent is not null
order by 3,4


--select*
--from PortfolioProject_new..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject_New..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject_New..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject_New..CovidDeaths
--where location like '%india%'
order by 1,2

-- looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases)AS HighestInfectionCount, MAX( (total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject_New..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_New..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

--showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_New..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject_New..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, population, vac. new_vaccinations
, sum(convert(int,vac.new_vaccinations))  over  (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject_New..CovidDeaths dea
join PortfolioProject_New..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3


 -- USE CTE

 with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations))  over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject_New..CovidDeaths dea
join PortfolioProject_New..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
	-- order by 2,3
)
select*, (rollingpeoplevaccinated/population)*100
from popvsvac

 --temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

 insert into #percentpopulationvaccinated
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations))  over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject_New..CovidDeaths dea
join PortfolioProject_New..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null
	-- order by 2,3

	select*, (rollingpeoplevaccinated/population)*100 
 from #percentpopulationvaccinated



 --creating view to store data for later visulizations

 create view percentpopulationvaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations))  over  (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject_New..CovidDeaths dea
join PortfolioProject_New..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from percentpopulationvaccinated