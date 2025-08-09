create database if not exists PortfolioProjects;
 use PortfolioProjects;
 
 create table CovidDeaths(
 iso_code	Varchar(255),
 continent	varchar(255),
 location	varchar(255),
 population int,
 date	date,
 total_cases	int,
 new_cases	int,
 total_deaths	int,
 new_deaths	int,
 icu_patients	int,
 hosp_patients	int,
 new_tests	int,
 total_tests	int,
 positive_rate	Decimal(10,2),
 total_vaccinations	int,
 people_vaccinated	int,
 people_fully_vaccinated	int,
 new_vaccinations int );

select * from CovidDeaths;

LOAD DATA local INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/portfolioprojects/CovidDeaths.csv'
INTO TABLE CovidDeaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Create table CovidVaccinations(
iso_code	varchar(255),
continent	varchar(255),
location	varchar(255),
population int,
date	date,
new_tests	int,
total_tests	int,
positive_rate	Decimal(10,2),
total_vaccinations	int,
people_vaccinated	int,
people_fully_vaccinated	int,
new_vaccinations int);

select * from CovidVaccinations;

LOAD DATA local INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Data/portfolioprojects/CovidVaccinations.csv'
INTO TABLE CovidVaccinations
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Queries exploring Covid Data till May 2021

Select * From CovidDeaths
Where continent is not null
Order By 3,4;


-- Select Data that we are going to be starting with

Select Location,total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
Select Location,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2;


-- Total Cases vs Population
Select Location,Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by 1,2;


-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2;


-- Global cumulative cases, deaths
SELECT
    MAX(date) AS as_of,
    SUM(total_cases) AS global_cases,
    SUM(total_deaths) AS global_deaths
FROM coviddeaths
WHERE continent IS NOT NULL;


-- Countries with highest peak daily new cases (absolute)
SELECT location,
       MAX(new_cases) AS peak_new_cases
FROM coviddeaths
WHERE continent IS NOT NULL
AND location != 'World'
GROUP BY location
ORDER BY peak_new_cases DESC
LIMIT 10;


-- Countries with the lowest CFR 
SELECT location,
       SUM(total_cases) AS total_cases,
       SUM(total_deaths) AS total_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING SUM(total_cases) >= 100000
LIMIT 10;


-- Which countries hit 70% fully vaccinated & when
SELECT location,
       MIN(date) AS date_reached_70pct
FROM covidvaccinations
WHERE continent IS NOT NULL
  AND people_fully_vaccinated >= 0.70 * population
GROUP BY location
ORDER BY date_reached_70pct;


-- Total population, Total Cases, Total Deaths by location
SELECT 
    location,
    MAX(population) AS total_population,
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths
FROM CovidDeaths
WHERE total_cases IS NOT NULL
  AND location != 'World'
GROUP BY location
ORDER BY total_cases DESC;


-- Top 10 countries with highest Covid cases
SELECT 
    location,
    MAX(total_cases) AS total_cases
FROM CovidDeaths
WHERE total_cases IS NOT NULL
  AND location != 'World'
GROUP BY location
ORDER BY total_cases DESC
LIMIT 10;



-- Top 10 Countries with highest Deaths
SELECT 
    location,
    MAX(total_deaths) AS total_deaths
FROM CovidDeaths
WHERE total_deaths IS NOT NULL
  AND location != 'World'
GROUP BY location
ORDER BY total_deaths DESC
LIMIT 10;


-- Top 10 countries with highest positive rate
SELECT 
    location,
    MAX(total_cases) AS total_cases,
    MAX(total_tests) AS total_tests,
    ROUND((MAX(total_cases) * 1.0 / NULLIF(MAX(total_tests), 0)) * 100, 2) AS positive_rate_percentage
FROM CovidDeaths
WHERE total_tests IS NOT NULL
  AND total_cases IS NOT NULL
  AND location != 'World'
GROUP BY location
HAVING MAX(total_tests) > 0
ORDER BY positive_rate_percentage DESC
LIMIT 10;


-- Top 10 countries with lowest cases
SELECT 
    location,
    MAX(total_cases) AS total_cases
FROM CovidDeaths
WHERE total_cases IS NOT NULL
  AND total_cases > 0
  AND location != 'World'
  AND continent IS NOT NULL
GROUP BY location
ORDER BY total_cases ASC
LIMIT 10;


-- Top 10 countries with lowest deaths
SELECT 
    location,
    MAX(total_deaths) AS total_deaths
FROM CovidDeaths
WHERE total_deaths IS NOT NULL
  AND total_deaths > 0
  AND location != 'World'
  AND continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths ASC
LIMIT 10;


-- Top 10 Countries by Fully Vaccinated People
SELECT 
    location,
    MAX(people_fully_vaccinated) AS fully_vaccinated
FROM CovidVaccinations
WHERE people_fully_vaccinated IS NOT NULL
  AND location != 'World'
  AND continent IS NOT NULL
GROUP BY location
ORDER BY fully_vaccinated DESC
LIMIT 10;


-- Case Fatality Rate (CFR) by Country
SELECT 
    location,
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths,
    ROUND(MAX(total_deaths) * 100.0 / MAX(total_cases), 2) AS case_fatality_rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY case_fatality_rate DESC;


-- Vaccination Coverage (Fully Vaccinated %)
SELECT 
    location,
    MAX(people_fully_vaccinated) AS fully_vaccinated,
    MAX(population) AS population,
    ROUND(MAX(people_fully_vaccinated) * 100.0 / MAX(population), 2) AS fully_vaccinated_percentage
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY fully_vaccinated_percentage DESC
LIMIT 10;


-- Countries with Zero Deaths but Cases
SELECT 
    location,
    MAX(total_cases) AS total_cases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(total_deaths) = 0
ORDER BY total_cases;


-- Countries Where Vaccinations Surpassed Population
SELECT 
    location,
    MAX(total_vaccinations) AS total_vaccinations,
    MAX(population) AS population
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(total_vaccinations) > MAX(population);


-- Global Vaccination Rate
SELECT 
    ROUND(SUM(people_fully_vaccinated) * 100.0 / SUM(population), 2)*100 AS global_fully_vaccinated_percentage
FROM CovidVaccinations
WHERE continent IS NOT NULL;


-- Top 10 Countries with the Highest Population Unvaccinated
SELECT 
    location,
    MAX(population) AS population,
    MAX(people_fully_vaccinated) AS fully_vaccinated,
    (MAX(population) - MAX(people_fully_vaccinated)) AS unvaccinated_population
FROM CovidVaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY unvaccinated_population DESC
LIMIT 10;

-- *** --