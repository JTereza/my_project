
-- otázka č. 2, vytvoření tabulek

-- informace o potravinách

SELECT 
	*,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name,
	YEAR 
ORDER BY
	cpc.name,
	YEAR;

-- informace o mzdách


SELECT 
	cp.value,
	cp.payroll_year,
	cp.payroll_quarter,
	cpib.name 
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
ON cp.industry_branch_code = cpib.code
WHERE 
	value_type_code = 5958 AND 
	value IS NOT NULL AND 
	industry_branch_code IS NOT NULL 
ORDER BY 
	cp.payroll_year;


-- vytvoření tabulek

CREATE TABLE t_tereza_jurakova_demo_price
SELECT 
	*,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name,
	YEAR 
ORDER BY
	cpc.name,
	YEAR;


-- propojení dvou tabulek

SELECT DISTINCT 
	cp.value AS price,
	cp.category_code,
	cp.name AS potraviny,
	cp.price_unit,
	cp2.value AS mzdy,
	cp2.payroll_year,
	cp2.industry_branch_code,
	cpib.name AS branch
FROM t_tereza_jurakova_demo_price cp
LEFT JOIN czechia_payroll cp2 
ON cp.YEAR = cp2.payroll_year 
LEFT JOIN czechia_payroll_industry_branch cpib 
ON cp2.industry_branch_code = cpib.code
WHERE 
cp2.value_type_code = 5958;


 -- vytvoření tabulky

CREATE OR REPLACE TABLE t_tereza_jurakova_project_SQL_primary_final
SELECT DISTINCT 
	cp.value AS price,
	cp.category_code,
	cp.name AS potraviny,
	cp.price_unit,
	cp2.value AS mzdy,
	cp2.payroll_year,
	cp2.industry_branch_code,
	cpib.name AS branch
FROM t_tereza_jurakova_demo_price cp
LEFT JOIN czechia_payroll cp2 
ON cp.YEAR = cp2.payroll_year 
LEFT JOIN czechia_payroll_industry_branch cpib 
ON cp2.industry_branch_code = cpib.code
WHERE 
cp2.value_type_code = 5958;

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
	min(mzdy)
FROM t_tereza_jurakova_project_sql_primary_final
WHERE 
	payroll_year IN ('2006', '2018')
GROUP BY 
	payroll_year;



 -- spojení mzdy + potraviny

SELECT DISTINCT 
	cp1.potraviny,
	cp1.price,
	cp1.payroll_year,
	cp2.min_mzdy
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
LEFT JOIN 
	(SELECT 
		payroll_year, 
		min(mzdy) AS min_mzdy
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
 -- zapomněla jsem jednotky:( - aktualizuji tabulku
 -- vypočteno SQL dotazem, ale v reálu bych vzala kalkulačku

SELECT DISTINCT 
	cp1.potraviny,
	cp1.price,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.price,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(mzdy) AS min_mzdy
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
	cp1.price,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.price,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(mzdy) AS min_mzdy
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
	cp1.price,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.price,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(mzdy) AS min_mzdy
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
	cp1.price,
	cp1.price_unit,
	cp1.payroll_year,
	cp2.min_mzdy,
	round(cp2.min_mzdy/cp1.price,0) AS result
FROM t_tereza_jurakova_project_sql_primary_final AS cp1
JOIN 
	(SELECT 
		payroll_year, 
		min(mzdy) AS min_mzdy
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
