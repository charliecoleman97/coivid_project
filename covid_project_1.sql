-- Select All rows of Covid Deaths table
Select * 
From PortfolioProject..CovidDeaths

-- Select Data to use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2;

-- Looking at Total Cases vs Total Deaths in UK
-- Shows rough liklihood of dying after contracting covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathRate
From PortfolioProject..CovidDeaths
Where location like '%United Kingdom%'
order by 1, 2;

-- Looking at Total Cases vs Total Deaths in US
-- Shows rough liklihood of dying after contracting covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathRate
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2;

-- Looking at Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2;

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population)*100) As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location, population
order by PercentPopulationInfected Desc;

-- Countries with the Highest Death Count per Population
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location, population
order by TotalDeathCount Desc;

-- Break down by continent

-- Continents with the Highest Death Count per Population
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
order by TotalDeathCount Desc;

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1, 2;

-- Total Global Deaths 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2;

-- Vaccination rolling count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- USE CTE
with PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

Drop Table if exists #PercentPopulationVaccinated
-- Temp Table 
Create table #PercentPopulationVaccinated
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
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
where dea.continent is not null 

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
-- Death percent view
Create View death_percent as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where continent is not null
group by date

-- 
Create View PercentPopVax as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	And dea.date = vac.date
where dea.continent is not null 
