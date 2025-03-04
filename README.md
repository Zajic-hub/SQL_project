# SQL Analýza dostupnosti potravin a mezd v ČR

## Přehled projektu
Tento projekt analyzuje růst mezd a cen potravin v ČR a Evropě za několik let a dokládá  tak dostupnost základních potravin široké veřejnosti

## Struktura souborů
- **Script_create_tables** – SQL skript pro vytvoření tabulek a vyřešení výzkumných otázek - zanamenán tak, jak probíhali mé úvahy, včetně toho, že někdy (by) bylo  efektivnějní využít Excel, neupraveno
- **t_drahomira_zajickova_project_SQL_primary_final – obsahuje data o mzdách a cenách potravin v ČR.
- **t_drahomira_zajickova_project_SQL_secondary_final – obsahuje data o HDP, GINI koeficientu a populaci dalších evropských států.
- **Researchquestions** – Excel soubor - odpovědi k výzkumným otázkám, vizualizace
- **README.md** – Dokumentace k projektu.

## Výzkumné otázky
1. Rostou mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik litrů mléka a kilogramů chleba bylo možné koupit za první a poslední rok?
3. Která kategorie potravin zdražuje nejpomaleji?
4. Existuje rok, kdy ceny potravin rostly výrazně rychleji než mzdy?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin?

## Použití
Spusťte skript `Script_create_tables.sql`, následně vizualizaci výsledků uvidíte v Excelu `Researchquestions.xls`.
