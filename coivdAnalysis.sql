-- select population, total_cases, (total_cases/population)*100 as covidProb from covidDeaths;
-- select *from covidDeaths
-- order by 3,4;

-- select * from covidVaccines
-- order by 3,4;


-- alter table covidDeaths 
-- alter column date TYPE DATE
-- USING date::date;

-- alter table covidVaccines
-- alter column date TYPE date
-- USING date::date;

-- Select Data that wwe are going to using
select location, date, total_cases, new_cases, total_deaths, population
from covidDeaths
order by 1,2;

--looking at total cases vs total deaths
--shos likelihood of dying if you contract covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage 
from covidDeaths 
where location like '%India%'
order by 1,2;

--looking at total cases vs Population
select location, date, total_cases, population,(total_cases/population)*100 as deathPercentage
from covidDeaths
where location like '%India'
order by 1,2;

-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highestInfectionCount,max((total_cases/population))*100 as percentagePopulationAffected
from covidDeaths
where continent is not null
group by location, population
order by percentagePopulationAffected desc;

--showing Countries with highest death count per population
select location, max(cast(total_deaths as int)) as totalDeathCount
from covidDeaths
where continent is not null
group by location
order by totalDeathCount desc;

-- shoing continent with highest deeath count
select continent, max(cast(total_deaths as int)) as totalDeathCount
from covidDeaths
where continent is not null
group by continent
order by totalDeathCount desc; 

-- global numbers
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,(sum(new_deaths)/sum(new_cases))*100 as perc
from covidDeaths
where continent is not null
-- group by date
order by 1,2;


-- Vaccinations join with covid deaths

select * from 
covidDeaths 
join covidVaccines
on covidDeaths.location=covidVaccines.location
and covidDeaths.date= covidVaccines.date;

-- looking at total population vs vaccinations

--use cte
With PopvsVac(continent, location, date, population,new_vaccinations,rollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations 
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date)
as rollingPeopleVaccinated
from covidDeaths as d
join covidVaccines as v
on d.location=v.location
and d.date=v.date
where d.continent is not null
-- and v.new_vaccinations is not null
-- order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100 as percentagePeopleVaccinated 
from PopvsVac;
-- with temp table
DROP table if exists PopvsVac;
create table PopvsVac(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccination numeric,
rollingPeopleVaccinated numeric
);
insert into PopvsVac(
select d.continent, d.location, d.date, d.population, v.new_vaccinations 
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date)
as rollingPeopleVaccinated
from covidDeaths as d
join covidVaccines as v
on d.location=v.location
and d.date=v.date
where d.continent is not null
);


select *, (rollingPeopleVaccinated/population)*100 as percentagePeopleVaccinated 
from PopvsVac;
 
-- CREATING view to store data for further analysis
drop table if exists PopvsVac;
create view PopvsVac as
select d.continent, d.location, d.date, d.population, v.new_vaccinations 
,sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date)
as rollingPeopleVaccinated
from covidDeaths as d
join covidVaccines as v
on d.location=v.location
and d.date=v.date
where d.continent is not null
 













