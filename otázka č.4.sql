

SELECT 
	*
FROM t_tereza_jurakova_project_sql_primary_final cp;

-- procentuální nárůst potravin

		SELECT 
			current_year.potraviny,
			current_year.average,
			current_year.current_year,
			previous_year.previous_average,
			previous_year.previous_year,
	CASE 
		WHEN previous_year.previous_average = 0 THEN NULL 
		ELSE round(((current_year.average - previous_year.previous_average)/previous_average)*100, 1)
	END AS ratio
FROM 
	(SELECT
		cp.potraviny,
		cp.average_potraviny AS average,
		cp.payroll_year AS current_year
	FROM 
		t_tereza_jurakova_project_sql_primary_final cp 
	GROUP BY 
		cp.potraviny,payroll_year
	ORDER BY 
		cp.potraviny,payroll_year) AS current_year
	LEFT JOIN 
		(SELECT
			cp.potraviny,
			cp.average_potraviny AS previous_average,
			cp.payroll_year AS previous_year
	FROM 
		t_tereza_jurakova_project_sql_primary_final cp 
	GROUP BY 
		cp.potraviny, previous_year
	ORDER BY 
		cp.potraviny, previous_year) AS previous_year
	ON 
		current_year.potraviny = previous_year.potraviny AND 
		current_year.current_year = previous_year.previous_year + 1;
	
	
	-- procentuální nárůst mezd
	
	

		SELECT 
			current_year.name,
			current_year.average,
			current_year.current_year,
			previous_year.previous_average,
			previous_year.previous_year,
	CASE 
		WHEN previous_year.previous_average = 0 THEN NULL 
		ELSE round(((current_year.average - previous_year.previous_average)/previous_average)*100, 1)
	END AS ratio
FROM 
	(SELECT
		cp.name,
		cp.average_mzdy AS average,
		cp.payroll_year AS current_year
	FROM 
		t_tereza_jurakova_project_sql_primary_final cp 
	GROUP BY 
		cp.name,payroll_year
	ORDER BY 
		cp.name,payroll_year) AS current_year
	LEFT JOIN 
		(SELECT
			cp.name,
			cp.average_mzdy AS previous_average,
			cp.payroll_year AS previous_year
	FROM 
		t_tereza_jurakova_project_sql_primary_final cp 
	GROUP BY 
		cp.name, previous_year
	ORDER BY 
		cp.name, previous_year) AS previous_year
	ON 
		current_year.name = previous_year.name AND 
		current_year.current_year = previous_year.previous_year + 1;
	
	

	
-- pokus o windows function - potraviny
	
WITH base AS ( 
		SELECT DISTINCT 
			potraviny,
			average_potraviny,
			payroll_year,
			LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_average_potraviny,
			LAG(payroll_year) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT * 
FROM base;
	
	

-- pokus o windows function - mzdy
	

WITH base AS ( 
		SELECT DISTINCT 
			name,
			average_mzdy,
			payroll_year,
			LAG(average_mzdy) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_average_mzdy,
			LAG(payroll_year) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT * 
FROM base;

-- nárůst - potraviny


WITH base AS ( 
		SELECT DISTINCT 
			potraviny,
			average_potraviny,
			payroll_year,
			LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_average_potraviny,
			LAG(payroll_year) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT 
	cp1.potraviny,
	cp1.payroll_year,
	cp1.average_potraviny,
	cp1.previous_average_potraviny,
	CASE 
		WHEN previous_average_potraviny = 0 THEN NULL 
		ELSE ROUND(((average_potraviny - previous_average_potraviny)/previous_average_potraviny)*100, 1)
	END AS ratio
FROM base cp1
GROUP BY 
	cp1.potraviny,
	cp1.payroll_year
ORDER BY 
	cp1.potraviny,
	cp1.payroll_year;

-- nárůst mzdy

WITH base AS ( 
		SELECT DISTINCT 
			name,
			average_mzdy,
			payroll_year,
			LAG(average_mzdy) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_average_mzdy,
			LAG(payroll_year) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT 
	cp1.name,
	cp1.payroll_year,
	cp1.average_mzdy,
	cp1.previous_average_mzdy,
	CASE 
		WHEN previous_average_mzdy = 0 THEN NULL 
		ELSE ROUND(((average_mzdy - previous_average_mzdy)/previous_average_mzdy)*100, 1)
	END AS ratio
FROM base cp1
GROUP BY 
	cp1.name,
	cp1.payroll_year
ORDER BY 
	cp1.name,
	cp1.payroll_year;


-- teď budu hledat maximum ratio z potravin a minimum ratio z mezd pro daný rok


-- minimum ratio mezd


WITH base AS ( 
		SELECT DISTINCT 
			name,
			average_mzdy,
			payroll_year,
			LAG(average_mzdy) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_average_mzdy,
			LAG(payroll_year) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT 
	cp1.name,
	cp1.payroll_year,
	CASE 
		WHEN previous_average_mzdy = 0 THEN NULL 
		ELSE ROUND(((average_mzdy - previous_average_mzdy)/previous_average_mzdy)*100, 1)
	END AS ratio_mezd
FROM base cp1
GROUP BY 
	cp1.name,
	cp1.payroll_year
HAVING min(ratio_mezd)
ORDER BY 
	cp1.name,
	cp1.payroll_year;



-- maximum ratio potravin


WITH base AS ( 
		SELECT DISTINCT 
			potraviny,
			average_potraviny,
			payroll_year,
			LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_average_potraviny,
			LAG(payroll_year) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT 
	cp1.potraviny,
	cp1.payroll_year,
	CASE 
		WHEN previous_average_potraviny = 0 THEN NULL 
		ELSE ROUND(((average_potraviny - previous_average_potraviny)/previous_average_potraviny)*100, 1)
	END AS ratio_potravin
FROM base cp1
GROUP BY 
	cp1.potraviny,
	cp1.payroll_year
HAVING max(ratio_potravin) > 10
ORDER BY 
	cp1.potraviny,
	cp1.payroll_year;


-- rozdíl ratio - vytvoření tabulek


CREATE TABLE t_tereza_jurakova_demo_ratio_potraviny
WITH base AS ( 
		SELECT DISTINCT 
			potraviny,
			average_potraviny,
			payroll_year,
			LAG(average_potraviny) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_average_potraviny,
			LAG(payroll_year) OVER (PARTITION BY potraviny ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT 
	cp1.potraviny,
	cp1.payroll_year,
	CASE 
		WHEN previous_average_potraviny = 0 THEN NULL 
		ELSE ROUND(((average_potraviny - previous_average_potraviny)/previous_average_potraviny)*100, 1)
	END AS ratio_potravin
FROM base cp1
GROUP BY 
	cp1.potraviny,
	cp1.payroll_year
ORDER BY 
	cp1.potraviny,
	cp1.payroll_year;


 -- mzdy



CREATE TABLE t_tereza_jurakova_demo_ratio_mzdy
WITH base AS ( 
		SELECT DISTINCT 
			name,
			average_mzdy,
			payroll_year,
			LAG(average_mzdy) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_average_mzdy,
			LAG(payroll_year) OVER (PARTITION BY name ORDER BY payroll_year) AS previous_year
		FROM t_tereza_jurakova_project_sql_primary_final cp
)	
SELECT DISTINCT 
	cp1.name,
	cp1.payroll_year,
	CASE 
		WHEN previous_average_mzdy = 0 THEN NULL 
		ELSE ROUND(((average_mzdy - previous_average_mzdy)/previous_average_mzdy)*100, 1)
	END AS ratio_mzdy
FROM base cp1
GROUP BY 
	cp1.name,
	cp1.payroll_year
ORDER BY 
	cp1.name,
	cp1.payroll_year;


-- spojení tabulek
	


SELECT *
FROM t_tereza_jurakova_demo_ratio_potraviny cp
LEFT JOIN t_tereza_jurakova_demo_ratio_mzdy cp1
ON cp.payroll_year = cp1.payroll_year;


-- odečtení ratio
-- převedení do excelu


SELECT 
	cp.potraviny,
	cp.payroll_year,
	cp1.name,
	cp.ratio_potravin,
	cp1.ratio_mzdy,
	cp.ratio_potravin - cp1.ratio_mzdy AS rozdil 
FROM 
	t_tereza_jurakova_demo_ratio_potraviny cp
LEFT JOIN
	t_tereza_jurakova_demo_ratio_mzdy cp1
ON
	cp.payroll_year = cp1.payroll_year;





