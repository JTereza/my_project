
-- otázka č. 2, vytvoření tabulek

-- informace o potravinách

SELECT
	*
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL
GROUP BY 
	cpc.name,
	cp.date_from 
ORDER BY 
	cpc.name;

-- průměr


SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 1) AS average_potraviny,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL 
GROUP BY 
	cpc.name, YEAR
ORDER BY 
	cpc.name, YEAR;


-- informace o mzdách


SELECT 
	cp.payroll_year,
	cpib.name,
	cp.calculation_code,
	AVG(cp.value) AS average_mzdy
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
ON cp.industry_branch_code = cpib.code
WHERE 
	value_type_code = 5958 AND 
	value IS NOT NULL AND 
	industry_branch_code IS NOT NULL AND 
	calculation_code = 100
GROUP BY 
	cpib.name,
	cp.payroll_year 
ORDER BY 
	cpib.name,
	cp.payroll_year;


-- vytvoření tabulek - potraviny

CREATE OR REPLACE TABLE t_tereza_jurakova_demo_price
SELECT 
	*,
	ROUND(AVG(value), 1) AS average_potraviny,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL
GROUP BY 
	cpc.name,
	YEAR 
ORDER BY
	cpc.name,
	YEAR;


-- vytvoření tabulek - mzdy

CREATE OR REPLACE TABLE t_tereza_jurakova_demo_mzdy
SELECT 
	cp.payroll_year,
	cpib.name,
	cp.calculation_code,
	AVG(cp.value) AS average_mzdy
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
ON cp.industry_branch_code = cpib.code
WHERE 
	value_type_code = 5958 AND 
	value IS NOT NULL AND 
	industry_branch_code IS NOT NULL AND 
	calculation_code = 100
GROUP BY 
	cpib.name,
	cp.payroll_year 
ORDER BY 
	cpib.name,
	cp.payroll_year;



-- propojení dvou tabulek

SELECT
	cp.value AS price,
	cp.category_code,
	cp.name AS potraviny,
	cp.price_unit,
	cp.average_potraviny,
	cp2.average_mzdy,
	cp2.payroll_year,
	cp2.name
FROM t_tereza_jurakova_demo_price cp
LEFT JOIN t_tereza_jurakova_demo_mzdy cp2
ON cp.`YEAR` = cp2.payroll_year;




 -- vytvoření tabulky

CREATE OR REPLACE TABLE t_tereza_jurakova_project_SQL_primary_final
SELECT
	cp.name AS potraviny,
	cp.price_unit,
	cp.average_potraviny,
	cp2.average_mzdy,
	cp2.payroll_year,
	cp2.name
FROM t_tereza_jurakova_demo_price cp
LEFT JOIN t_tereza_jurakova_demo_mzdy cp2
ON cp.`YEAR` = cp2.payroll_year;
	
	
  -- otázka


SELECT *
FROM t_tereza_jurakova_project_sql_primary_final
WHERE 
	potraviny LIKE ('Chléb%') OR  
	potraviny LIKE ('Mléko%')
ORDER BY potraviny;




 -- pro roky


SELECT *
FROM t_tereza_jurakova_project_sql_primary_final
WHERE 
	(potraviny LIKE 'Chléb%' OR  
	potraviny LIKE 'Mléko%') AND 
	payroll_year IN ('2006', '2018')
ORDER BY potraviny;

 -- srovnání se mzdou


SELECT 
	payroll_year, 
	name,
	min(average_mzdy)
FROM t_tereza_jurakova_project_sql_primary_final
WHERE 
	payroll_year IN ('2006', '2018')
GROUP BY 
	payroll_year;



 -- spojení mzdy + potraviny

SELECT DISTINCT 
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.payroll_year,
	cp2.min_mzdy
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
LEFT JOIN 
	(SELECT 
		payroll_year, 
		min(average_mzdy) AS min_mzdy
	FROM t_tereza_jurakova_project_sql_primary_final
	WHERE 
		payroll_year IN ('2006', '2018')
	GROUP BY 
		payroll_year) AS cp2
ON cp1.payroll_year = cp2.payroll_year
WHERE 
	(cp1.potraviny LIKE 'Chléb%' OR  
	cp1.potraviny LIKE 'Mléko%') AND 
	cp1.payroll_year IN ('2006', '2018')
ORDER BY 
	cp1.potraviny;

		
 -- počty

SELECT DISTINCT 
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.average_potraviny,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(average_mzdy) AS min_mzdy
	FROM t_tereza_jurakova_project_sql_primary_final
	WHERE 
		payroll_year IN ('2018')
	GROUP BY 
		payroll_year) AS cp2
ON cp1.payroll_year = cp2.payroll_year
WHERE 
	cp1.potraviny LIKE 'Chléb%'  AND  
	cp1.payroll_year = '2018'
ORDER BY 
	cp1.potraviny;

-- rok 2006,chléb

SELECT DISTINCT 
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.average_potraviny,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(average_mzdy) AS min_mzdy
	FROM t_tereza_jurakova_project_sql_primary_final
	WHERE 
		payroll_year IN ('2006')
	GROUP BY 
		payroll_year) AS cp2
ON cp1.payroll_year = cp2.payroll_year
WHERE 
	cp1.potraviny LIKE 'Chléb%'  AND  
	cp1.payroll_year = '2006'
ORDER BY 
	cp1.potraviny;
		

 -- rok 2018, mléko


SELECT DISTINCT 
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.average_potraviny,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(average_mzdy) AS min_mzdy
	FROM t_tereza_jurakova_project_sql_primary_final
	WHERE 
		payroll_year IN ('2018')
	GROUP BY 
		payroll_year) AS cp2
ON cp1.payroll_year = cp2.payroll_year
WHERE 
	cp1.potraviny LIKE 'Mléko%'  AND  
	cp1.payroll_year = '2018'
ORDER BY 
	cp1.potraviny;


 -- rok 2006, mléko

SELECT DISTINCT 
	cp1.potraviny,
	cp1.average_potraviny,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.average_potraviny,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(average_mzdy) AS min_mzdy
	FROM t_tereza_jurakova_project_sql_primary_final
	WHERE 
		payroll_year IN ('2006')
	GROUP BY 
		payroll_year) AS cp2
ON cp1.payroll_year = cp2.payroll_year
WHERE 
	cp1.potraviny LIKE 'Mléko%'  AND  
	cp1.payroll_year = '2006'
ORDER BY 
	cp1.potraviny;
