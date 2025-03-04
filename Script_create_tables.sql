
/*
-----------------------------------------------------------------------------------
SQL Skript pro analýzu vývoje mezd a cen potravin v ČR + evropská data (HDP, GINI)
Autor: Drahomíra Zajíčková, nemám Discord, kontakt je email: drahomira.fischlova@seznam.cz
Účel: Vytvoření tabulek a analýza dostupnosti základních potravin ve vztahu k příjmům
Struktura skriptu:
    1️ Analýza vývoje mezd v čase
    2️ Analýza kupní síly (chleba a mléko)
    3️ Analýza cen potravin a meziročního růstu
    4️ Vytvoření finálních tabulek pro další analýzu
    5️ Export dat pro zpracování v Excelu
-----------------------------------------------------------------------------------
*/


-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- 5958  -- Průměrná hrubá mzda na zaměstnance

SELECT * 
FROM czechia_payroll 
WHERE value_type_code = 5958;

SELECT 
    payroll_year AS year,  
    AVG(value) AS avg_salary
FROM czechia_payroll
WHERE value_type_code = 5958
GROUP BY payroll_year
ORDER BY payroll_year;


--spojení mzdy a odvetvi

SELECT 
    czechia_payroll.payroll_year AS year, 
    czechia_payroll_industry_branch.name AS industry,  
    AVG(czechia_payroll.value) AS avg_salary
FROM czechia_payroll
JOIN czechia_payroll_industry_branch 
    ON czechia_payroll.industry_branch_code = czechia_payroll_industry_branch.code
WHERE czechia_payroll.value_type_code = 5958  
GROUP BY czechia_payroll.payroll_year, czechia_payroll_industry_branch.name
ORDER BY czechia_payroll.payroll_year, czechia_payroll_industry_branch.name;


-- Otázka 2: Kolik lze koupit mléka a chleba?

-- chleba - 111301
-- mléko - 114201

--  průměrné mzdy v jednotlivých letech

SELECT 
    payroll_year AS year,  
    AVG(value) AS avg_salary
FROM czechia_payroll
WHERE value_type_code = 5958
GROUP BY payroll_year
ORDER BY payroll_year;

-- průměrné ceny mléka a chleba podle roku

CREATE TABLE milk_prices AS
SELECT 
    date_from AS year,  
    AVG(value) AS milk_price
FROM czechia_price
WHERE category_code = 114201
GROUP BY date_from;

CREATE TABLE bread_prices AS
SELECT 
    date_from AS year,  
    AVG(value) AS bread_price
FROM czechia_price
WHERE category_code = 111301
GROUP BY date_from;

-- separatni tabulky pro chleba a mleko do jedne tabulky

CREATE TABLE food_prices AS
SELECT 
    milk_prices.year, 
    milk_prices.milk_price, 
    bread_prices.bread_price
FROM milk_prices
JOIN bread_prices 
    ON milk_prices.year = bread_prices.year;
   
 -- vytvoreni tabulky pro prumerne mzdy
   
CREATE TABLE salaries AS
SELECT 
    payroll_year AS year,  
    AVG(value) AS avg_salary
FROM czechia_payroll
WHERE value_type_code = 5958
GROUP BY payroll_year
ORDER BY payroll_year;

SELECT * 
FROM salaries 
LIMIT 5;

SELECT* 
FROM food_prices 
LIMIT 5;

-- úprava celé tabulky food_prices na food_prices_fixed , abych mohla spojit, měla jsem rozdílně formát year

CREATE TABLE food_prices_fixed AS
SELECT 
    YEAR(year) AS year,  
    milk_price, 
    bread_price
FROM food_prices;


-- spojení obou tabulek: salaries a food_prices_fixed

CREATE TABLE food_affordability AS
SELECT 
    salaries.year, 
    salaries.avg_salary,
    food_prices_fixed.milk_price, 
    food_prices_fixed.bread_price,
    salaries.avg_salary / food_prices_fixed.milk_price AS liters_of_milk,
    salaries.avg_salary / food_prices_fixed.bread_price AS kg_of_bread
FROM salaries
JOIN food_prices_fixed 
    ON salaries.year = food_prices_fixed.year;


SELECT* 
FROM food_affordability 
LIMIT 10;

-- teď tabulku food_affordability překopíruji do tabulky se správným názvem t_drahomira_zajickova_project_SQL_primary_final

CREATE TABLE t_drahomira_zajickova_project_SQL_primary_final AS
SELECT* 
FROM food_affordability;

SELECT* 
FROM t_drahomira_zajickova_project_sql_primary_final tdzpspf
LIMIT 10;

-- dále byl export tabulky a zpracování v excelu


-- Otázka č. 3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

-- vytvoření tabulky z czechia_price jen se sloupci, se kterými pracuji na tabulku czechia_price_clean_1 a tvorba roku

CREATE TABLE czechia_price_clean_1 AS
SELECT 
    YEAR(date_from) AS year,  
    category_code,
    value AS price
FROM czechia_price;

-- přidání názvů kategorií k číselným kódům - jako např. 111101 - Rýže a tvorba;  
-- kde sloučím  czechia_price_clean_1 a czechia_proce_category (jedná se o jen ověření, zda funguje správně)

SELECT 
    czechia_price_clean_1.year,  
    czechia_price_clean_1.category_code,  
    czechia_price_clean_1.price,  
    czechia_price_category.name  
FROM czechia_price_clean_1
JOIN czechia_price_category 
    ON czechia_price_clean_1.category_code = czechia_price_category.code;
   
 
-- vytvoření tabulky avg_food_prices s průměrnými cenami potravin podle let
--  spočítám průměrné ceny potravin za každý rok a kategorii
   
CREATE TABLE avg_food_prices AS
SELECT 
    czechia_price_clean_1.year,  
    czechia_price_category.name AS product_category,  
    AVG(czechia_price_clean_1.price) AS avg_price
FROM czechia_price_clean_1
JOIN czechia_price_category 
    ON czechia_price_clean_1.category_code = czechia_price_category.code
GROUP BY czechia_price_clean_1.year, czechia_price_category.name
ORDER BY czechia_price_clean_1.year, czechia_price_category.name;


DROP TABLE IF EXISTS avg_food_prices;  
CREATE TABLE avg_food_prices AS
SELECT 
    czechia_price_clean_1.year,  
    czechia_price_category.name,  
    AVG(czechia_price_clean_1.price) AS avg_price
FROM czechia_price_clean_1
JOIN czechia_price_category 
    ON czechia_price_clean_1.category_code = czechia_price_category.code
GROUP BY czechia_price_clean_1.year, czechia_price_category.name
ORDER BY czechia_price_clean_1.year, czechia_price_category.name;
 
-- tuto tabulku už si expoertuji do excelu, kde budu pokračovat v analýze, Excel jsem zvolila, že si myslím, 
-- že tyto drobné úpravy kze dělat již efektivněji v excelu než pomocí SQL (otázka zodpovězena v rámci analýzy v excelu)


-- Třetí výzkumná otázka 
-- byla zodpovězena v excelu, kdy jsem měla z předchozích kroků pomocí SQL vyexportované tabulky 
-- a lehce jsme mohla provést analýzu v Excelu, aniž jsme zatěžovala kapacitu Dbeaver


-- Úkol - Tvorba druhé tabulky ve formátu t_drahomira_zajickova_project_SQL_secondary_final

-- budu propojovat tabulky economies a countries, abych dostala k sobě všechna potřebná data 

-- ověření přes co propojit

SELECT DISTINCT country 
FROM economies 
ORDER BY country
LIMIT 10;


SELECT DATABASE();
SHOW DATABASES;
USE engeto_08_2024_dz;
SELECT DATABASE();

SELECT DISTINCT country 
FROM countries
ORDER BY country
LIMIT 10;

-- spojím oba soubory

SELECT 
    economies.year,  
    economies.country,  
    economies.gdp,  
    economies.population,  
    economies.gini,  
    countries.region_in_world
FROM economies
JOIN countries 
    ON economies.country = countries.country
ORDER BY 
	economies.year, 
	economies.country;

-- vidím dost NULL hodnot, ověřím, kde tyto NULL vznikají !!!LEFT JOIN!!!

SELECT 
    economies.year,  
    economies.country,  
    economies.gdp,  
    economies.population,  
    economies.gini,  
    countries.region_in_world
FROM economies
LEFT JOIN countries 
    ON economies.country = countries.country
WHERE countries.region_in_world IS NULL;


-- vytvořím tabulku t_drahomira_zajickova_project_SQL_secondary_final

CREATE TABLE t_drahomira_zajickova_project_SQL_secondary_final AS
SELECT 
    economies.year,  
    economies.country,  
    economies.gdp,  
    economies.population,  
    economies.gini,  
    countries.region_in_world
FROM economies
LEFT JOIN countries 
    ON economies.country = countries.country
ORDER BY 
	economies.year, 
	economies.country;

-- Třetí výzkumná otázka- Má HDP vliv na změny ve mzdách a cenách potravin? 
-- toto nenbudu analyzovat, vytvořím pouze tabulku, ze které to bude možné dovodit

-- ověření tabulek, které jsem vytvořila (špatně označeno, nepamatuji si)

SELECT 
	table_name, 
	create_time 
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
ORDER BY 
	create_time DESC;

-- Vytvoření pomocné tabulky avg_food_prices_yearly

DROP TABLE IF EXISTS avg_food_prices_yearly;

CREATE TABLE avg_food_prices_yearly AS
SELECT 
    year, 
    AVG(avg_price)
FROM avg_food_prices
GROUP BY year;

-- Smazání staré tabulky

DROP TABLE IF EXISTS t_Drahomira_Zajickova_project_SQL_primary_final;

-- opravení sloupce v avg_food_prices

DROP TABLE IF EXISTS avg_food_prices_yearly;

CREATE TABLE avg_food_prices_yearly AS
SELECT 
    year,  
    AVG(avg_price) AS avg_food_price  -- Opravený název sloupce
FROM avg_food_prices
GROUP BY year;

-- vytvoření správné finální tabulky primary_final

DROP TABLE IF EXISTS t_Drahomira_Zajickova_project_SQL_primary_final;

CREATE TABLE t_Drahomira_Zajickova_project_SQL_primary_final AS
SELECT 
    avg_food_prices.year,  
    czechia_price_category.code AS category_code,  
    avg_food_prices.name AS category_name,  
    avg_food_prices.avg_price,  
    avg_food_prices_yearly.avg_food_price, 
    salaries.avg_salary,  
    food_affordability.milk_price,  
    food_affordability.bread_price
FROM avg_food_prices
LEFT JOIN czechia_price_category 
    ON avg_food_prices.name = czechia_price_category.name  
LEFT JOIN salaries 
    ON avg_food_prices.year = salaries.year
LEFT JOIN avg_food_prices_yearly
    ON avg_food_prices.year = avg_food_prices_yearly.year
LEFT JOIN food_affordability
    ON avg_food_prices.year = food_affordability.year;


-- kontrolou v excelu obsahuje tabulka vše potřebné pro zdopovězení výzkumných otázek
-- např. využití kontingenčních tabulek
   
   
   /*
    * Výzkumná otázka Má výška HDP vliv na změny ve mzdách a cenách potravin? 
    */
   
   
-- sloučení dat pro tuto otázku v excelu bylo poměrně komplikované, vrátila jsem se ke slučování v SQL
 

   CREATE TABLE t_merge_GDP_price_salary AS
SELECT 
    tdzpspf.year,  
    tdzpssf.country,  
    tdzpssf.gdp,  
    tdzpssf.population,  
    tdzpssf.gini,  
    tdzpssf.region_in_world,  
    tdzpspf.avg_food_price,  
    tdzpspf.avg_salary,  
    tdzpspf.milk_price,  
    tdzpspf.bread_price
FROM t_drahomira_zajickova_project_sql_primary_final tdzpspf
LEFT JOIN t_drahomira_zajickova_project_sql_secondary_final tdzpssf 
    ON tdzpspf.year = tdzpssf.year  
ORDER BY tdzpspf.year, tdzpssf.country;


select*
from t_merge_gdp_price_salary tmgps ;

-- tento skript vygeneroval přes milion řádků - nelze pokračovat


-- alternativně budu počítat pouze s průměrné hodnoty za všechny země v každém roce, takto by šlo i v excelu

DROP TABLE IF EXISTS t_merge_gdp_price_salary;


 CREATE TABLE t_drahomira_zajickova_project_SQL_aggregated AS
SELECT 
    tdzpspf.year,  
    AVG(tdzpssf.gdp) AS avg_gdp,  
    AVG(tdzpssf.population) AS avg_population,  
    AVG(tdzpssf.gini) AS avg_gini,  
    AVG(tdzpspf.avg_food_price) AS avg_food_price,  
    AVG(tdzpspf.avg_salary) AS avg_salary,  
    AVG(tdzpspf.milk_price) AS avg_milk_price,  
    AVG(tdzpspf.bread_price) AS avg_bread_price
FROM t_drahomira_zajickova_project_sql_primary_final tdzpspf
LEFT JOIN t_drahomira_zajickova_project_sql_secondary_final tdzpssf 
    ON tdzpspf.year = tdzpssf.year  
GROUP BY tdzpspf.year
ORDER BY tdzpspf.year;
 
   
ALTER TABLE t_drahomira_zajickova_project_SQL_aggregated 
RENAME TO t_gdp_prices_salary;
