Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4


-- Select Data that we are going to be using.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2



-- Looking at Total Cases vs Total Deaths.
-- Shows the likelihood of dying if you contract covid in your country.

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2



-- Looking at Total Cases vs The Population.
-- Shows what percentage of population got covid.

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2



-- Looking at Countries with Highest Infection rate compared to Populaion.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population 
order by PercentPopulationInfected desc



-- Showing the Countries with Highest Death Count per Population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Let's Break Things Down by Continent
-- Showing Continents with the Highest Death Count 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc

 
 -- Global Numbers

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From Portfolioproject..CovidDeaths$
 -- Where location like '%states%'
 Where continent is not null
 -- Group by date
 order by 1,2

 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From Portfolioproject..CovidDeaths$
 -- Where location like '%states%'
 Where continent is not null
 Group by date
 order by 1,2



 -- Looking at Total Population vs Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated,
 -- (RollingPeopleVaccinated/population)*100
 From Portfolioproject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
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
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to Store Data for Later Visualizations 


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 -- ,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated



