Select * 
From [PortfolioProject].[dbo].['owid-covid-data$']
order by 3,4


-- Order by the number as the first and second item select in the select statement 
Select Location, Date, total_cases,new_cases,total_deaths,population
From [PortfolioProject].[dbo].['owid-covid-data$']
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Change the total_deaths from nvarchar to float 
Alter table [PortfolioProject].[dbo].['owid-covid-data$']
Alter COLUMN  total_deaths float; 
Alter table [PortfolioProject].[dbo].['owid-covid-data$']
Alter COLUMN  total_cases float; 

Select Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate
From [PortfolioProject].[dbo].['owid-covid-data$']
Where total_deaths is not null AND location like '%states'
order by 1,2

-- Looking at TotalCases vs Population 
-- Show what percentage of population got covid 
Select Location, Date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From [PortfolioProject].[dbo].['owid-covid-data$']
Where total_cases is not null AND location like '%states'
order by 1,2;

-- Looking at Countries with Highest Infection rate compared to population 
SELECT
    Location,
	population,
    Max(total_cases) as HighestInfectionRate,
    max((total_cases/population))*100 as PercentPopulationInfected
   
FROM [PortfolioProject].[dbo].['owid-covid-data$']
-- Where total_cases IS NOT NULL AND location LIKE '%states'
GROUP BY Location, 
	population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with Highest Death Count per population 
SELECT
    Location,

    Max(total_deaths) as HighestDeathCount

   
FROM [PortfolioProject].[dbo].['owid-covid-data$']
Where continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC;

-- Break it down with continent and show the highest death count in each continent 
SELECT
    continent,

    Max(total_deaths) as HighestDeathCount

-- Looking at Total Population vs Vaccinations 
FROM [PortfolioProject].[dbo].['owid-covid-data$']
Where continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global Numbers - check how many new cases each date 
Select date, sum(new_cases)as NewCasesPerDate, sum(new_deaths) as DeathPerDate 
From [PortfolioProject].[dbo].['owid-covid-data$']
Group by date 
order by 1

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccincated
From [PortfolioProject].[dbo].['owid-covid-data$'] dea
Join  [PortfolioProject].[dbo].[CovidVaccinations$] vac
On dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3

-- USE CTE 
With populationvsVaccination (Continent, Location,Date, Population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccincated
From [PortfolioProject].[dbo].['owid-covid-data$'] dea
Join  [PortfolioProject].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
)
Select * , (RollingPeopleVaccinated/Population)*100 as vaccincationPercentages
from populationvsVaccination
order by 1,2

-- Use Temp Table 
Drop table if exists #PercentPopulationVaccinated 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccincated
From [PortfolioProject].[dbo].['owid-covid-data$'] dea
Join  [PortfolioProject].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100 as vaccincationPercentages
from #PercentPopulationVaccinated

-- Creating view to store data for later visualiztions 
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RolingPeopleVaccincated
From [PortfolioProject].[dbo].['owid-covid-data$'] dea
Join  [PortfolioProject].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null
