create database portfolio_project;
use portfolio_project;

drop table covid_deaths_final

create table covid_deaths_final
(
iso_code varchar(10),	
continent varchar(20),	
location varchar(30),	
date varchar(30),
population bigint,
total_cases	bigint,
new_cases bigint,
new_cases_smoothed	bigint,
total_deaths bigint,	
new_deaths	bigint,
new_deaths_smoothed	bigint,
total_cases_per_million	bigint,
new_cases_per_million	bigint,
new_cases_smoothed_per_million	bigint,
total_deaths_per_million	bigint,
new_deaths_per_million	bigint,
new_deaths_smoothed_per_million	bigint,
reproduction_rate bigint,	
icu_patients	bigint,
icu_patients_per_million	bigint,
hosp_patients	bigint,
hosp_patients_per_million	bigint,
weekly_icu_admissions	bigint,
weekly_icu_admissions_per_million	bigint,
weekly_hosp_admissions	bigint,
weekly_hosp_admissions_per_million bigint);

SHOW GLOBAL VARIABLES LIKE 'local_infile';
set global local_infile = 1; 

OPT_LOCAL_INFILE = 1
lastConnected=1673596134
serverVersion=8.0.31

load data local infile 'D:/CovidDeaths_final1.csv' into table covid_deaths_final
 fields terminated by ','
 enclosed by '"' lines terminated by '\n' ignore 1 rows ;
 
select * from covid_deaths_final;
set global max_allowed_packet = 2097152000

create table covid_vaccination
(
iso_code varchar(10),	
continent varchar(20),	
location varchar(30),
`date` varchar(30),	
new_tests bigint,	
total_tests	bigint,
total_tests_per_thousand bigint,	
new_tests_per_thousand bigint,	
new_tests_smoothed bigint,	
new_tests_smoothed_per_thousand bigint,	
positive_rate bigint,	
tests_per_case bigint,	
tests_units bigint,	
total_vaccinations bigint,	
people_vaccinated bigint,	
people_fully_vaccinated bigint,
new_vaccinations bigint,	
new_vaccinations_smoothed bigint,	
total_vaccinations_per_hundred bigint,	
people_vaccinated_per_hundred bigint,	
people_fully_vaccinated_per_hundred	bigint,
new_vaccinations_smoothed_per_million bigint,	
stringency_index bigint,	
population_density	bigint,
median_age	bigint,
aged_65_older	bigint,
aged_70_older	bigint,
gdp_per_capita	bigint,
extreme_poverty	bigint,
cardiovasc_death_rate bigint,	
diabetes_prevalence	bigint,
female_smokers	bigint,
male_smokers	bigint,
handwashing_facilities bigint,	
hospital_beds_per_thousand	bigint,
life_expectancy	bigint,
human_development_index bigint);

load data local infile 'D:/Covidvaccinations_final.csv' into table covid_vaccination
 fields terminated by ','
 enclosed by '"' lines terminated by '\n' ignore 1 rows ;
 
 select * from covid_deaths_final;
 select * from covid_vaccination;

select location, `date`, total_cases, new_cases, total_deaths, population 
from covid_deaths_final 

-- lokking at total_cases vs total_deaths --
-- how many cases are there in the country and how many deaths they have in the entire cases --
-- what is the percentage of the people wh died --

select location, `date`, total_cases, total_deaths, round((total_deaths/total_cases) * 100,2) as death_percentage
from covid_deaths_final 

select location, `date`, total_cases, total_deaths, round((total_deaths/total_cases) * 100,2) as death_percentage
from covid_deaths_final 
where location = 'India';  -- this shows the likelihood of dying if you contact COVID in your country --

-- looking at total_cases vs total_population  --
-- shows what percentage of population got COVID --
select location, `date`, total_cases, population, round((total_cases/population) * 100,2) as percent_of_population_infected
from covid_deaths_final;

-- this shows specifically for India --

select location, `date`, total_cases, population, round((total_cases/population) * 100,2) as percent_of_population_infected
from covid_deaths_final 
where location = 'India' 

-- looking at countries with highest infection rate compared to population --

select location, max(total_cases), population, 
max(round((total_cases/population) * 100,2)) as percent_of_population_infected
from covid_deaths_final 
Group by location
order by percent_of_population_infected desc;

-- showing countries with highest death count per population --
select location, continent, max(total_deaths) as total_death_count
from covid_deaths_final 
where continent is not null
Group by location
order by total_death_count desc;
-- let's break the data in the continent wise -- 

select continent, max(total_deaths) as total_death_count
from covid_deaths_final 
where continent is not null
Group by continent
order by total_death_count desc;

-- showing continents with highest death_count per population --
select continent, max(total_deaths) as total_death_count
from covid_deaths_final 
where continent is not null
Group by continent
order by total_death_count desc;

-- Global Numbers --
select `date`, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from covid_deaths_final
group by `date`

select `date`, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, round(sum(new_deaths)/sum(new_cases) * 100,2) as death_percentage
from covid_deaths_final
where continent is not null
group by `date`

select sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths, 
round(sum(new_deaths)/sum(new_cases) * 100,2) as death_percentage
from covid_deaths_final

select * from covid_vaccination

-- lokking at total_populations vs vaccinations

select d.continent, d.location, d.population, d.date, v.new_vaccinations, 
sum(v.new_vaccinations) as rolling_people_vaccinated
from covid_deaths_final d
join covid_vaccination v on d.location =v.location
and d.date = v.date
group by d.location
order by 2,4;


-- by using cte --
with popvsvac as
(select d.continent, d.location, d.population, d.date, v.new_vaccinations, 
sum(v.new_vaccinations) as rolling_people_vaccinated
from covid_deaths_final d
join covid_vaccination v on d.location =v.location
and d.date = v.date
group by d.location
order by 2,4)
select continent, location, date, population, rolling_people_vaccinated,
(rolling_people_vaccinated/population) * 100
from popvsvac

-- creating view to store data for  later visualization --
create view percent_population_vaccinated as
select d.continent, d.location, d.population, d.date, v.new_vaccinations, 
sum(v.new_vaccinations) as rolling_people_vaccinated
from covid_deaths_final d
join covid_vaccination v on d.location =v.location
and d.date = v.date
group by d.location
order by 2,4

select * from percent_population_vaccinated;


