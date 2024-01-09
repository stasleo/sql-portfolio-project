--Select Location, date, total_cases, new_cases, total_deaths, population
--FROM StanislauPortfolioProject.dbo.CovidDeaths
--order by 1,2

---- Total Cases vs. Total Death
--SELECT Location, date, total_cases, total_deaths, 
--	CASE 
--        WHEN total_cases = 0 OR total_cases IS NULL THEN NULL
--        ELSE ROUND(total_deaths/total_cases*100,2) 
--    END AS death_case_ratio
--FROM  StanislauPortfolioProject.dbo.CovidDeaths
--WHERE Location = 'Poland'
--ORDER BY Location, date;


-- Total Cases vs. Population
SELECT Location, date, total_cases, population, 
	CASE 
        WHEN total_cases = 0 OR total_cases IS NULL THEN NULL
        ELSE ROUND(total_cases/population*100,2) 
    END AS cases_per_population
FROM  StanislauPortfolioProject.dbo.CovidDeaths
WHERE Location = 'belarus'
ORDER BY date;


-- Deaths vs. Population
SELECT Location, date, total_deaths, population, 
	CASE 
        WHEN total_deaths = 0 OR total_deaths IS NULL THEN NULL
        ELSE ROUND(total_deaths/population*100,2) 
    END AS deaths_per_population
FROM  StanislauPortfolioProject.dbo.CovidDeaths
WHERE Location = 'belarus'
ORDER BY date;




---- countries with worst death by population ratio.
--WITH LatestDates AS (
--    SELECT MAX(date) AS MaxDate, location
--    FROM StanislauPortfolioProject.dbo.CovidDeaths
--    GROUP BY location
--)
--SELECT  cd.location, cd.date, cd.total_deaths, cd.population, 
--	cv.people_vaccinated_per_hundred,
--	CASE 
--        WHEN cd.total_deaths = 0 OR cd.total_deaths IS NULL THEN NULL
--        ELSE ROUND(cd.total_deaths/cd.population*100,2) 
--    END AS death_percentage
--FROM  StanislauPortfolioProject.dbo.CovidDeaths cd
--INNER JOIN LatestDates ld ON cd.date = ld.MaxDate AND cd.location = ld.location
--LEFT JOIN StanislauPortfolioProject.dbo.CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
--WHERE cd.total_deaths > 0
--ORDER BY death_percentage desc;





-- countries with worst InfectionRate in Europe
SELECT  location, population, max(total_cases) as HighestInvectionCount, max((total_cases/cast(population as float))*100) as InfectionRate
FROM CovidDeaths
where continent = 'europe'
group by location, population
order by 4 desc





-- countries with worst DeathRate in Europe
SELECT  location, population, max(total_deaths) as TotalDeathCount, max((total_deaths/population)*100) as DeathRate
FROM CovidDeaths
where continent = 'europe'
group by location, population
order by 4 desc


-- countries with max deaths
SELECT  location, max(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent <> ''
group by location
order by TotalDeathCount desc


-- continents with max deaths
SELECT  location, max(total_deaths) as TotalDeathCount
FROM CovidDeaths
WHERE continent = ''
group by location
order by TotalDeathCount desc


-- Total Numbers globally per day -- 
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent <> ''
	AND (new_cases > 0)
group by date
order by 1,2


-- Total Numbers worldwide -- 
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent <> ''
	AND (new_cases > 0)
order by 1,2


-- total population vs vaccinations
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, sum(convert(int,cast(CV.new_vaccinations as float))) 
	OVER (PARTITION BY CD.location order by CD.location, CD.date) 
	as totalVaccinated
, round(totalVaccinated/CD.population*100,2) as vaccinationRate
FROM StanislauPortfolioProject..CovidDeaths as CD
JOIN StanislauPortfolioProject..CovidVaccinations as CV
	ON  CD.Date = CV.Date 
	AND CD.Location = CV.Location
WHERE CD.location = 'Poland'
Order by 2,3


With PopulationVsVaccinations (continent,location,date,population,new_vaccinations,totalVaccinated)
as
(
	Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
	, sum(convert(int,cast(CV.new_vaccinations as float))) 
		OVER (PARTITION BY CD.location order by CD.location, CD.date) 
		as totalVaccinated
	FROM StanislauPortfolioProject..CovidDeaths as CD
	JOIN StanislauPortfolioProject..CovidVaccinations as CV
		ON  CD.Date = CV.Date 
		AND CD.Location = CV.Location
	WHERE CD.location = 'Poland'
)
Select *, (totalVaccinated/cast(population as float)) as PercentPopulationVaccinated
From PopulationVsVaccinations


Create View PercentPopulationVaccinated as
	Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
		, sum(convert(int,cast(CV.new_vaccinations as float))) 
			OVER (PARTITION BY CD.location order by CD.location, CD.date) 
			as totalVaccinated
		FROM StanislauPortfolioProject..CovidDeaths as CD
		JOIN StanislauPortfolioProject..CovidVaccinations as CV
			ON  CD.Date = CV.Date 
			AND CD.Location = CV.Location
		WHERE CD.location = 'Poland' 