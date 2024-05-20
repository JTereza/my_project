

SELECT *
FROM czechia_price cp;

SELECT*
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code;


-- v tabulce jsou průměry za ČR

SELECT
	cp.value,
	cp.category_code,
	cp.date_from,
	cpc.name 
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE region_code IS NULL;



-- průměr, roky - kde region code je NULL
-- ověřuji si data
SELECT
	cp.value,
	cp.region_code,
	cp.category_code,
	cp.date_from,
	cpc.name
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL AND 
	cpc.name LIKE 'Banány%'
GROUP BY 
	cpc.name,
	cp.date_from,
	cp.region_code 
ORDER BY 
	cpc.name;


-- pro všechny potraviny

SELECT
	cp.value,
	cp.category_code,
	cp.date_from,
	cpc.name
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


-- která varianta bude lepší?

SELECT
	cp.value,
	cp.region_code,
	cp.category_code,
	cp.date_from,
	cpc.name
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE  
	cpc.name LIKE 'Banány%'
GROUP BY 
	cpc.name,
	cp.date_from,
	cp.region_code 
ORDER BY 
	cpc.name;




SELECT
	cp.value,
	cp.category_code,
	cp.date_from,
	cpc.name,
	cp.region_code,
	ROUND(AVG(value), 2) AS average
FROM 
	czechia_price cp 
LEFT JOIN 
	czechia_price_category cpc 
ON 
	cp.category_code = cpc.code
WHERE 
	cp.region_code IS NOT NULL AND 
	cpc.name LIKE 'Banány%'
GROUP BY 
	cpc.name,
	cp.region_code
ORDER BY 
	cpc.name,
	cp.date_from ;


-- vybírám variantu region_code IS NULL
-- current year

SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 1) AS average,
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



-- previous year

SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 1) AS average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR,
	EXTRACT(YEAR FROM cp.date_from) - 1 AS previous_YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL 
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
	ROUND(AVG(value), 1) AS average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL 
GROUP BY 
	cpc.name, YEAR
ORDER BY 
	cpc.name, YEAR) AS current_year
LEFT JOIN 
(SELECT
	cp.value,
	cpc.name,
	ROUND(AVG(value), 1) AS previous_average,
	EXTRACT(YEAR FROM cp.date_from) AS YEAR,
	EXTRACT(YEAR FROM cp.date_from) - 1 AS previous_YEAR
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
WHERE 
	cp.region_code IS NULL 
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
		ROUND(AVG(cp.value), 1) AS average,
		EXTRACT(YEAR FROM cp.date_from) AS year
	FROM 
		czechia_price cp 
	LEFT JOIN 
		czechia_price_category cpc ON cp.category_code = cpc.code
	WHERE 
		cp.region_code IS NULL 
	GROUP BY 
		cpc.name, year
	ORDER BY 
		cpc.name, year) AS current_year
	LEFT JOIN 
		(SELECT
			cpc.name,
			ROUND(AVG(cp.value), 1) AS previous_average,
			EXTRACT(YEAR FROM cp.date_from) AS previous_year
	FROM 
		czechia_price cp 
	LEFT JOIN 
		czechia_price_category cpc ON cp.category_code = cpc.code
	WHERE 
		cp.region_code IS NULL 
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
	WHERE 
		cp.region_code IS NULL
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
	WHERE 
		cp.region_code IS NULL
	GROUP BY 
		cpc.name, previous_year
	ORDER BY 
		cpc.name, previous_year) AS previous_year
	ON 
		current_year.name = previous_year.name AND 
		current_year.year = previous_year.previous_year + 1;

