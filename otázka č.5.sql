



SELECT *
FROM
	economies cp
LEFT JOIN
	demographics cp1
ON 
	cp.`year` = cp1.`year` AND 
	cp.country = cp1.country 
LEFT JOIN 
	religions cp2
ON 
	cp.`year` =cp2.`year` AND 
	cp.country = cp2.country 
	
	
	
-- výběr údajů
	

SELECT DISTINCT 
	cp.country ,
	cp.`year`,
	cp.GDP,
	cp.population,
	cp.gini,
	cp.taxes,
	cp.fertility,
	cp.mortaliy_under5,
	cp1.death_rate_per_thousand,
	cp1.birth_rate_per_thousand,
	cp2.region,
	cp2.religion,
	cp2.population 
FROM
	economies cp
LEFT JOIN
	demographics cp1
ON 
	cp.`year` = cp1.`year` AND 
	cp.country = cp1.country 
LEFT JOIN 
	religions cp2
ON 
	cp.`year` =cp2.`year` AND 
	cp.country = cp2.country 
ORDER BY 
	cp.country;


-- vytvoření tabulky

CREATE TABLE t_tereza_jurakova_project_sql_secondary_final
SELECT DISTINCT 
	cp.country ,
	cp.`year`,
	cp.GDP,
	cp.population,
	cp.gini,
	cp.taxes,
	cp.fertility,
	cp.mortaliy_under5,
	cp1.death_rate_per_thousand,
	cp1.birth_rate_per_thousand,
	cp2.region,
	cp2.religion,
	cp2.population AS population_religion
FROM
	economies cp
LEFT JOIN
	demographics cp1
ON 
	cp.`year` = cp1.`year` AND 
	cp.country = cp1.country 
LEFT JOIN 
	religions cp2
ON 
	cp.`year` =cp2.`year` AND 
	cp.country = cp2.country 
ORDER BY 
	cp.country;




--  HDP Czech Republic

SELECT*
FROM t_tereza_jurakova_project_sql_secondary_final
WHERE 
	country LIKE '%cz%'
	
	
-- propojení tabulek
	
SELECT DISTINCT 
	cp.country,
	cp.`year`,
	cp.GDP,
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.name,
	cp1.average_mzdy 
FROM t_tereza_jurakova_project_sql_secondary_final cp
LEFT JOIN t_tereza_jurakova_project_sql_primary_final cp1
ON cp.`year` = cp1.payroll_year
WHERE 
	country LIKE 'Czech%';

-- vytvoření tabulky


CREATE TABLE t_tereza_jurakova_demo_HDP
SELECT DISTINCT 
	cp.country,
	cp.`year`,
	cp.GDP,
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.name,
	cp1.average_mzdy 
FROM t_tereza_jurakova_project_sql_secondary_final cp
LEFT JOIN t_tereza_jurakova_project_sql_primary_final cp1
ON cp.`year` = cp1.payroll_year
WHERE 
	country LIKE 'Czech%';


-- previous_year



SELECT DISTINCT 
	current_year.`year`,
	current_year.GDP,
	previous_year.previous_year,
	previous_year.previous_gdp
FROM t_tereza_jurakova_demo_hdp current_year
LEFT JOIN
	(SELECT DISTINCT 
		cp.`year` AS previous_year,
		cp.GDP AS previous_gdp
	FROM t_tereza_jurakova_demo_hdp cp) AS previous_year
ON 
	current_year.`year` = previous_year.previous_year +1
ORDER BY 
	`year`;

-- výpočet ratio
	

SELECT DISTINCT 
	current_year.country,
	current_year.`year`,
	current_year.GDP,
	previous_year.previous_year,
	previous_year.previous_gdp,
	CASE 
		WHEN previous_year.previous_GDP = 0 THEN NULL 
		ELSE round(((current_year.GDP - previous_year.previous_GDP)/previous_GDP)*100, 2)
	END AS ratio
FROM t_tereza_jurakova_demo_hdp current_year
LEFT JOIN
	(SELECT DISTINCT 
		cp.`year` AS previous_year,
		cp.GDP AS previous_gdp
	FROM t_tereza_jurakova_demo_hdp cp) AS previous_year
ON 
	current_year.`year` = previous_year.previous_year +1
ORDER BY 
	current_year.`year`,
	current_year.country;


-- spojení tabulky




SELECT *
FROM t_tereza_jurakova_demo_ratio_potraviny cpp
LEFT JOIN 
(SELECT 
	cp1.name,
	cp1.payroll_year,
	cp1.ratio_mzdy,
	ratio_GDP_CZ.country,
	ratio_GDP_CZ.YEAR,
	ratio_GDP_CZ.ratio_GDP
FROM t_tereza_jurakova_demo_ratio_mzdy cp1
LEFT JOIN 
	(SELECT DISTINCT 
		current_year.country,
		current_year.`year`,
		current_year.GDP,
		previous_year.previous_year,
		previous_year.previous_gdp,
		CASE 
			WHEN previous_year.previous_GDP = 0 THEN NULL 
			ELSE round(((current_year.GDP - previous_year.previous_GDP)/previous_GDP)*100, 2)
		END AS ratio_GDP
	FROM t_tereza_jurakova_demo_hdp current_year
	LEFT JOIN
		(SELECT DISTINCT 
			cp.`year` AS previous_year,
			cp.GDP AS previous_gdp
		FROM t_tereza_jurakova_demo_hdp cp) AS previous_year
	ON 
		current_year.`year` = previous_year.previous_year +1
	ORDER BY 
		current_year.`year`,
		current_year.country) ratio_GDP_CZ
ON 
	cp1.payroll_year = ratio_GDP_CZ.YEAR) mzdy_GDP
ON 
	cpp.payroll_year = mzdy_GDP.YEAR;


-- pomocí windows function - GDP


WITH base AS (
	SELECT DISTINCT 
		cp.country,
		cp.YEAR,
		cp.GDP,
		LAG(GDP) OVER (PARTITION BY country ORDER BY year) AS previous_GDP,
		lag(year) OVER (PARTITION BY country ORDER BY year) AS previous_year
	FROM t_tereza_jurakova_demo_hdp cp)
SELECT *
FROM base;


-- mzdy


WITH base AS (
	SELECT DISTINCT 
		cp.name,
		cp.YEAR,
		cp.average_mzdy,
		LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) AS previous_average_mzdy,
		lag(year) OVER (PARTITION BY name ORDER BY year) AS previous_year
	FROM t_tereza_jurakova_demo_hdp cp)
SELECT *
FROM base;


-- potraviny

WITH base AS (
	SELECT DISTINCT 
		cp.potraviny,
		cp.YEAR,
		cp.average_potraviny,
		LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) AS previous_average_potraviny,
		lag(year) OVER (PARTITION BY name ORDER BY year) AS previous_year
	FROM t_tereza_jurakova_demo_hdp cp)
SELECT *
FROM base;


-- ratio GDP

WITH base AS (
	SELECT DISTINCT 
		cp.country,
		cp.YEAR,
		cp.GDP,
		LAG(GDP) OVER (PARTITION BY country ORDER BY year) AS previous_GDP,
		lag(year) OVER (PARTITION BY country ORDER BY year) AS previous_year,
		CASE 
			WHEN LAG(GDP) OVER (PARTITION BY country ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((GDP - LAG(GDP) OVER (PARTITION BY country ORDER BY year)) / LAG(GDP) OVER (PARTITION BY country ORDER BY year)) * 100, 2) 
		END AS ratio_GDP		
	FROM t_tereza_jurakova_demo_hdp cp
	WHERE 
		cp.GDP IS NOT NULL)
SELECT *
FROM base;


-- ratio mzdy


WITH base AS (
	SELECT DISTINCT 
		cp.name,
		cp.YEAR,
		cp.average_mzdy,
		LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) AS previous_average_mzdy,
		lag(year) OVER (PARTITION BY name ORDER BY year) AS previous_year,
		CASE 
			WHEN LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((average_mzdy - LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year)) / LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year)) * 100, 1) 
		END AS ratio_mzdy		
	FROM t_tereza_jurakova_demo_hdp cp
	WHERE 
		cp.GDP IS NOT NULL)
SELECT *
FROM base;


-- ratio potravin


WITH base AS (
	SELECT DISTINCT 
		cp.potraviny,
		cp.YEAR,
		cp.average_potraviny,
		LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) AS previous_average_potraviny,
		lag(year) OVER (PARTITION BY potraviny ORDER BY year) AS previous_year,
		CASE 
			WHEN LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((average_potraviny - LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year)) / LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year)) * 100, 1) 
		END AS ratio_potraviny		
	FROM t_tereza_jurakova_demo_hdp cp
	WHERE 
		cp.GDP IS NOT NULL)
SELECT *
FROM base;

-- dohromady

WITH base AS (
SELECT DISTINCT		
		cp.country,
		cp.YEAR,
		cp.GDP,
		LAG(GDP) OVER (PARTITION BY country ORDER BY year) AS previous_GDP,
		lag(year) OVER (PARTITION BY country ORDER BY year) AS previous_year_GDP,
		CASE 
			WHEN LAG(GDP) OVER (PARTITION BY country ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((GDP - LAG(GDP) OVER (PARTITION BY country ORDER BY year)) / LAG(GDP) OVER (PARTITION BY country ORDER BY year)) * 100, 2) 
		END AS ratio_GDP,
		cp.name,
		cp.average_mzdy,
		LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) AS previous_average_mzdy,
		lag(year) OVER (PARTITION BY name ORDER BY year) AS previous_year_mzdy,
		CASE 
			WHEN LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((average_mzdy - LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year)) / LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year)) * 100, 1) 
		END AS ratio_mzdy,
		cp.potraviny,
		cp.average_potraviny,
		LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) AS previous_average_potraviny,
		lag(year) OVER (PARTITION BY potraviny ORDER BY year) AS previous_year_potraviny,
		CASE 
			WHEN LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((average_potraviny - LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year)) / LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year)) * 100, 1) 
		END AS ratio_potraviny		
	FROM t_tereza_jurakova_demo_hdp cp
	WHERE 
		cp.GDP IS NOT NULL)
SELECT*
FROM base;

-- zjednodušení

WITH base AS (
SELECT DISTINCT		
		cp.country,
		cp.YEAR,
		cp.GDP,
		LAG(GDP) OVER (PARTITION BY country ORDER BY year) AS previous_GDP,
		CASE 
			WHEN LAG(GDP) OVER (PARTITION BY country ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((GDP - LAG(GDP) OVER (PARTITION BY country ORDER BY year)) / LAG(GDP) OVER (PARTITION BY country ORDER BY year)) * 100, 2) 
		END AS ratio_GDP,
		cp.name,
		cp.average_mzdy,
		LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) AS previous_average_mzdy,
		CASE 
			WHEN LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((average_mzdy - LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year)) / LAG(average_mzdy) OVER (PARTITION BY name ORDER BY year)) * 100, 1) 
		END AS ratio_mzdy,
		cp.potraviny,
		cp.average_potraviny,
		LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) AS previous_average_potraviny,
		CASE 
			WHEN LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year) = 0 THEN NULL 
			ELSE ROUND(((average_potraviny - LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year)) / LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY year)) * 100, 1) 
		END AS ratio_potraviny		
	FROM t_tereza_jurakova_demo_hdp cp
	WHERE 
		cp.GDP IS NOT NULL)
SELECT
	YEAR,
	ratio_GDP,
	name,
	ratio_mzdy,
	potraviny,
	ratio_potraviny
FROM base;

