

SELECT *
FROM czechia_price cp;

SELECT*
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code;




SELECT
	cp.value,
	cp.category_code,
	cp.date_from,
	cpc.name 
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code;


-- průměr, roky

SELECT
	cp.value,
	cp.category_code,
	cp.date_from,
	cpc.name,
	ROUND(AVG(value), 2) AS average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name, YEAR
ORDER BY 
	cpc.name, YEAR;



-- current year

SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 2) AS average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name, YEAR
ORDER BY 
	cpc.name, YEAR;



-- previous year

SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 2) AS average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR,
	EXTRACT(YEAR FROM cp.date_from) - 1 AS previous_YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name, year
ORDER BY 
	cpc.name, year;


 -- dohromady



SELECT *
FROM 
(SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 2) AS average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name, YEAR
ORDER BY 
	cpc.name, YEAR) AS current_year
LEFT JOIN 
(SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 2) AS previous_average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR,
	EXTRACT(YEAR FROM cp.date_from) - 1 AS previous_YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY 
	cpc.name, year
ORDER BY 
	cpc.name, year) AS previous_year
ON 
	current_year.name = previous_year.name AND 
	current_year.YEAR = previous_year.YEAR;


 -- selekt hodnot
-- oprava výpočtu předchozího roku

SELECT 
	current_year.name,
	current_year.average,
	current_year.year,
	previous_year.previous_average,
	previous_year.previous_year
FROM 
	(SELECT
		cpc.name,
		ROUND(AVG(cp.value), 2) AS average,
		EXTRACT(YEAR FROM cp.date_from) AS year
	FROM 
		czechia_price cp 
	LEFT JOIN 
		czechia_price_category cpc ON cp.category_code = cpc.code
	GROUP BY 
		cpc.name, year
	ORDER BY 
		cpc.name, year) AS current_year
	LEFT JOIN 
		(SELECT
			cpc.name,
			ROUND(AVG(cp.value), 2) AS previous_average,
			EXTRACT(YEAR FROM cp.date_from) AS previous_year
	FROM 
		czechia_price cp 
	LEFT JOIN 
		czechia_price_category cpc ON cp.category_code = cpc.code
	GROUP BY 
		cpc.name, previous_year
	ORDER BY 
		cpc.name, previous_year) AS previous_year
	ON 
		current_year.name = previous_year.name AND 
		current_year.year = previous_year.previous_year + 1;	


 -- výpočet procent
-- final do excelu

SELECT 
	current_year.name,
	current_year.average,
	current_year.year,
	previous_year.previous_average,
	previous_year.previous_year,
	CASE 
		WHEN previous_year.previous_average = 0 THEN NULL 
		ELSE round(((current_year.average - previous_year.previous_average)/previous_average)*100, 2)
	END AS ratio
FROM 
	(SELECT
		cpc.name,
		ROUND(AVG(cp.value), 2) AS average,
		EXTRACT(YEAR FROM cp.date_from) AS year
	FROM 
		czechia_price cp 
	LEFT JOIN 
		czechia_price_category cpc ON cp.category_code = cpc.code
	GROUP BY 
		cpc.name, year
	ORDER BY 
		cpc.name, year) AS current_year
	LEFT JOIN 
		(SELECT
			cpc.name,
			ROUND(AVG(cp.value), 2) AS previous_average,
			EXTRACT(YEAR FROM cp.date_from) AS previous_year
	FROM 
		czechia_price cp 
	LEFT JOIN 
		czechia_price_category cpc ON cp.category_code = cpc.code
	GROUP BY 
		cpc.name, previous_year
	ORDER BY 
		cpc.name, previous_year) AS previous_year
	ON 
		current_year.name = previous_year.name AND 
		current_year.year = previous_year.previous_year + 1;

