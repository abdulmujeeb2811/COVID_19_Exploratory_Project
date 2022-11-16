select *
from Portfolio_Project..CovidDeaths
order by 3,4

Select * 
from Portfolio_Project..CovidDeaths
order by 3,4

--Data for Exploration

--Total cases by date
Select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2

--Total Cases vs Total deaths
Select location, date, total_cases, total_deaths, total_deaths/total_cases * 100 as Percentage_death
From Portfolio_project..CovidDeaths
where location = 'Nigeria'
order by 1,2

--Rate of Occurence in population
Select location, date, population, total_cases, (total_cases/population) * 100 as Incidence_rate
From Portfolio_project..CovidDeaths
--where location = 'Nigeria'
order by 1,2

--Countries ranked by Incidence rate
Select location, population, max (total_cases), max((total_cases/population) * 100) as Incidence_rate_Country
From Portfolio_project..CovidDeaths
where continent is not null
group by population, location
order by Incidence_rate_Country desc

--Countries ranked by Death Occurence
Select location, max(cast(total_deaths as int)) as TotalDeath
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by TotalDeath desc

--Continents ranked by Death Occurence
Select location, max(cast(total_deaths as int)) as TotalDeath
from Portfolio_Project..CovidDeaths
where continent is null
and location != 'World'
group by location
order by TotalDeath desc

--Continents  ranked by Death Percentage 
Select location, max(total_cases) as Infected, max(cast(total_deaths as int)) as Deaths , max(cast(total_deaths as int))/ max (total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is null
and location != 'World'
group by location
Order by DeathPercentage desc

--Global Death rate 
Select sum( new_cases) as Total_Global_Cases, sum(cast(new_deaths as int)) as Total_Global_Death, sum(cast(new_deaths as int))/sum( new_cases) *100 as World_Death_Percentage
from Portfolio_Project..CovidDeaths
where continent is not null
 
order by 3


Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_people_by_day
from Portfolio_Project ..CovidDeaths  dea
join Portfolio_Project..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;


--Using CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Vaccinated_people_by_day)
as
(Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_people_by_day
from Portfolio_Project ..CovidDeaths  dea
join Portfolio_Project..CovidVaccinations  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
from PopvsVac;

--Create a table of Percent Population Vaccinated

Create Table Perc_Pop_Vac (Continent nvarchar (255), Location nvarchar (255), Date datetime, 
Population numeric, new_vaccinations numeric, Vaccinated_people_by_day numeric
)
Insert into Perc_Pop_Vac
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_people_by_day
from Portfolio_Project ..CovidDeaths  dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, Vaccinated_people_by_day/Population*100 as Percentage_Vaccinated
from Perc_Pop_Vac