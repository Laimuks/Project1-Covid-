select location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..coviddata
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Countries with highest death count per population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..coviddata
where continent is not null
group by location
order by TotalDeathCount desc

--Death count per population by continent
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..coviddata
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as numeric)) as Total_Deaths, SUM(cast(new_deaths as numeric))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..coviddata
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as numeric)) as Total_Deaths, SUM(cast(new_deaths as numeric))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..coviddata
where continent is not null 
--Group By date
order by 1,2

--joining 2 tables
--- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddata dea
Join Portfolio..vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
-- PercentagePeopleVaccinated

With PopvsVac (Continent, Location, Date, Population, People_Fully_Vaccinated, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, people_fully_vaccinated, vac.new_vaccinations 
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddata dea
Join Portfolio..vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (people_fully_vaccinated/Population)*100 as PercentagePeopleVaccinated
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
People_Fully_Vaccinated numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, people_fully_vaccinated, vac.new_vaccinations 
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddata dea
Join Portfolio..vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (people_fully_vaccinated/Population)*100 as PercentagePeopleVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
USE Portfolio
GO
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..coviddata dea
Join Portfolio..vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


USE Portfolio
GO
Create View TotalDeathCount as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..coviddata
where continent is not null
group by location


USE Portfolio
GO
Create View TotalDeathCountContinents as
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..coviddata
where continent is null
group by location


USE Portfolio
GO
Create View DailyDeathPercentage as
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as numeric)) as Total_Deaths, SUM(cast(new_deaths as numeric))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..coviddata
--Where location like '%states%'
where continent is not null 
Group By date


