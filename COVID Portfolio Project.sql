Select*
From portfolioProject..CovidDeaths
--Where continent is not null
order by 3,4



--Select*
--From portfolioProject..Covidvaccinations
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at countries with highest Infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From portfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing the Countries with Highest Death Count Per Population

Select Location,MAX(Cast(Total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Let's Break Things Down As Continent
-- showing continents with the highest death count per population
Select continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
From portfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Looking at total Population Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with  PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)
From PopvsVac


-- TEMP TABLE


Drop Table If exists #PercentPopulationVaccinated
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
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select*, (RollingPeopleVaccinated/Population)
From #PercentPopulationVaccinated



--Creating a view to store data for later visualization


Drop View if exists PercentPopulationVaccinated
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated 