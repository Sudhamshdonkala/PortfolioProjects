# COVID-19 Data Exploration using SQL

## 📋 Overview
This project explores global COVID-19 data using **SQL Server** to uncover key insights about infection rates, death percentages, and vaccination progress across countries and continents.  

The dataset used comes from **Our World in Data**, containing information on COVID-19 deaths and vaccinations. The goal is to analyze, clean, and visualize the data for deeper understanding and reporting.

---

## 📂 Dataset Information
**Databases Used:**
- `PortfolioProject_New..CovidDeaths`
- `PortfolioProject_New..CovidVaccinations`

**Key Columns:**
- `location` – Country or region name  
- `continent` – Continent name  
- `date` – Observation date  
- `total_cases`, `new_cases` – COVID-19 case counts  
- `total_deaths`, `new_deaths` – Death counts  
- `population` – Country’s population  
- `new_vaccinations` – Daily vaccination numbers  

---

## 🔍 SQL Queries & Analysis Performed

### 1️⃣ Data Preview
```sql
SELECT *
FROM PortfolioProject_New..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;
```
Retrieves initial data to ensure structure and data quality.

---

### 2️⃣ Total Cases vs. Total Deaths
```sql
SELECT location, date, total_cases, total_deaths, 
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject_New..CovidDeaths
WHERE location LIKE '%india%'
AND continent IS NOT NULL
ORDER BY 1,2;
```
Shows **death percentage** to understand the likelihood of dying if infected by COVID-19 in a specific country.

---

### 3️⃣ Total Cases vs. Population
```sql
SELECT location, date, total_cases, population, 
       (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject_New..CovidDeaths
ORDER BY 1,2;
```
Calculates what **percentage of the population** contracted COVID-19.

---

### 4️⃣ Countries with Highest Infection Rate
```sql
SELECT location, population, 
       MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject_New..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
```
Identifies countries most affected by COVID relative to their population.

---

### 5️⃣ Countries and Continents with Highest Death Counts
```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject_New..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
```
Breakdown of **death counts by country** and **continent** to find global hotspots.

---

### 6️⃣ Global Summary
```sql
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS INT)) AS total_deaths,
       SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject_New..CovidDeaths
WHERE continent IS NOT NULL;
```
Provides a **global perspective** of total cases, deaths, and overall fatality rate.

---

### 7️⃣ Vaccination Progress (Join + Window Function)
```sql
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
       SUM(CONVERT(INT,vac.new_vaccinations)) 
           OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject_New..CovidDeaths dea
JOIN PortfolioProject_New..CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
```
Calculates **rolling vaccination totals** per country to track vaccination progress over time.

---

### 8️⃣ Using a CTE for Vaccination Percentage
```sql
WITH popvsvac AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM PortfolioProject_New..CovidDeaths dea
  JOIN PortfolioProject_New..CovidVaccinations vac
       ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM popvsvac;
```
Uses a **Common Table Expression (CTE)** to compute vaccination percentage relative to population.

---

### 9️⃣ Temporary Table for Reuse
Creates a temp table to store vaccination data for further analysis.

```sql
DROP TABLE IF EXISTS #percentpopulationvaccinated;
CREATE TABLE #percentpopulationvaccinated (
  continent NVARCHAR(255),
  location NVARCHAR(255),
  date DATETIME,
  population NUMERIC,
  new_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM PortfolioProject_New..CovidDeaths dea
JOIN PortfolioProject_New..CovidVaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date;
```

---

### 🔟 Creating a View for Visualization
```sql
CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject_New..CovidDeaths dea
JOIN PortfolioProject_New..CovidVaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```
This **view** simplifies access for visualization tools like **Power BI** or **Tableau**.

---

## 📈 Insights
- Countries like the **United States, India, and Brazil** show the highest infection and death counts.  
- Smaller countries often have **higher infection percentages** relative to population.  
- **Vaccination rollout** correlates with reduced new case and death rates.  

---

## 🧰 Tools Used
- **Microsoft SQL Server / SSMS** – Data exploration and query execution  
- **Excel / Power BI (optional)** – Visualization and dashboard creation  
- **Our World in Data (OWID)** – Source dataset  

--- 

## 📊 Tableau Dashboard — COVID-19 Insights

This **Tableau Dashboard** visually represents the findings from the SQL analysis.  
It combines key metrics, geographical trends, and time-based patterns to show how COVID-19 spread and impacted different regions globally.

### 🧮 Dashboard Components

#### **1️⃣ Global Numbers**
A summary table showing:
- **Total Deaths:** 3,180,206  
- **Total Cases:** 150,574,977  
- **Death Percentage:** 2.11%  

➡️ Gives a quick snapshot of global COVID-19 impact.

---

#### **2️⃣ Total Deaths per Continent**
A bar chart comparing total deaths across continents.  
- **North America** and **South America** recorded the highest death counts.  
- **Asia** and **Europe** follow, while **Africa** and **Oceania** show lower numbers.

➡️ This visualization highlights how the pandemic’s severity differed by region.

---

#### **3️⃣ Percent Population Infected per Country (Map View)**
A **world map** showing infection percentages by country.  
- Darker shades represent **higher infection rates**.  
- Countries like the **United States**, **Brazil**, and parts of **Europe** show the highest infection rates.

➡️ Provides a global overview of COVID-19 spread intensity.

---

#### **4️⃣ Percent Population Infected (Trend Line)**
A **line graph** showing infection growth over time for major countries:
- **United States:** ~19% infection rate by late 2021  
- **United Kingdom:** ~15%  
- **India:** ~9%  
- **Mexico:** ~3%  

➡️ Demonstrates the pace and trend of infection spread from early 2020 through 2021.

---

### 🧠 Insights from the Dashboard
- The **global death rate (~2%)** aligns with early WHO data on case fatality ratio.  
- **North and South America** had the highest death tolls, suggesting healthcare strain and high transmission.  
- **Vaccination rollout** (not visualized here but linked to SQL analysis) began reducing infection and death growth by mid-2021.  
- Visuals confirm the effectiveness of combining **SQL data cleaning** with **Tableau visual storytelling**.

---


