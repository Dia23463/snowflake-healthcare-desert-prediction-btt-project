
// making my own database and schema so i don't manipulate original database.
CREATE DATABASE IF NOT EXISTS MY_DB;
USE DATABASE MY_DB;
CREATE SCHEMA IF NOT EXISTS MY_SCHEMA;
USE SCHEMA MY_SCHEMA;

USE DATABASE MY_DB;
USE SCHEMA MY_SCHEMA;
USE WAREHOUSE SYSTEM$STREAMLIT_NOTEBOOK_WH;

// getting providers by ZIP code
CREATE TABLE providers_by_zip AS
SELECT 
    IVT_SRC_ZIP_CD AS zip_code,
    COUNT(DISTINCT IVT_SRC_ENRLMT_ID) AS num_providers
FROM ALLINCLUSIVE_SPARKSOFT_DATA_PACKAGE.PUBLISHED_WEB.V_PECOS_QTRLY_PRACTICELOCATION_LST
WHERE IVT_FILE_CMNT IN (
  SELECT MAX(IVT_FILE_CMNT) FROM ALLINCLUSIVE_SPARKSOFT_DATA_PACKAGE.PUBLISHED_WEB.V_PECOS_QTRLY_PRACTICELOCATION_LST
)
    AND IVT_SRC_STATE_CD = 'NY'
GROUP BY IVT_SRC_ZIP_CD;

// show first 5 rows of data for providers ZIP
SELECT * FROM providers_by_zip LIMIT 5; 



USE DATABASE MY_DB;
USE SCHEMA MY_SCHEMA;
USE WAREHOUSE SYSTEM$STREAMLIT_NOTEBOOK_WH;

CREATE OR REPLACE TABLE population_by_zip AS
SELECT 
    ZIP_CODE AS zip_code,
    ("TOT_CENSUS_POP_2010" + "TOT_CENSUS_POP_2011" + "TOT_CENSUS_POP_2012" + "TOT_CENSUS_POP_2013" + "TOT_CENSUS_POP_2014" + "TOT_CENSUS_POP_2015" + "TOT_CENSUS_POP_2016" + "TOT_CENSUS_POP_2017" + "TOT_CENSUS_POP_2018" + "TOT_CENSUS_POP_2019" + "TOT_CENSUS_POP_2020" + "TOT_CENSUS_POP_2021" + "TOT_CENSUS_POP_2022") AS total_population
FROM US_POPULATION_FORECAST_BY_ZIPCODE_20102035.INDICES_SCH.POPULATION_FORECAST_ZIPCODE
WHERE STATE_CODE = 'NY'
  AND COUNTRY_NAME = 'US';

// show first 5 rows of data for pop. ZIP
SELECT * FROM population_by_zip LIMIT 5;


// combining both tables based on similar zip code

SELECT 
    pop.zip_code AS pop_zip,
    pop.total_population,
    prov.num_providers
FROM (
    SELECT LPAD(SUBSTR(zip_code, 1, 5), 5, '0') AS zip_code, total_population
    FROM population_by_zip
) AS pop
LEFT JOIN (
    SELECT LPAD(SUBSTR(zip_code, 1, 5), 5, '0') AS zip_code, num_providers
    FROM providers_by_zip
) AS prov
ON pop.zip_code = prov.zip_code
ORDER BY pop.zip_code
LIMIT 100;


// creating a new table with aggregated values of population total and num total in each zip code
USE DATABASE MY_DB;
USE SCHEMA MY_SCHEMA;
USE WAREHOUSE SYSTEM$STREAMLIT_NOTEBOOK_WH;

CREATE OR REPLACE TABLE providers_population_summary AS
SELECT 
    LPAD(SUBSTR(pop.zip_code, 1, 5), 5, '0') AS zip_code,
    SUM(pop.total_population) AS total_population,
    SUM(prov.num_providers) AS total_providers
FROM population_by_zip pop
LEFT JOIN providers_by_zip prov
    ON LPAD(SUBSTR(pop.zip_code, 1, 5), 5, '0') = LPAD(SUBSTR(prov.zip_code, 1, 5), 5, '0')
GROUP BY LPAD(SUBSTR(pop.zip_code, 1, 5), 5, '0')
ORDER BY zip_code;

// show this table
SELECT * FROM providers_population_summary LIMIT 50;


WITH percentiles AS (
    SELECT
        PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY total_providers) AS p33,
        PERCENTILE_CONT(0.66) WITHIN GROUP (ORDER BY total_providers) AS p66
    FROM providers_population_summary
)
CREATE OR REPLACE TABLE zip_provider_classification AS
SELECT 
    pps.zip_code,
    pps.total_providers,
    CASE
        WHEN total_providers <= p.p33 THEN 'Low'
        WHEN total_providers <= p.p66 THEN 'Medium'
        ELSE 'High'
    END AS provider_density_class
FROM providers_population_summary pps
CROSS JOIN percentiles p;



-- // classification- high/medium/low
-- CREATE OR REPLACE TABLE zip_provider_classification AS
-- SELECT 
--     zip_code,
--     total_providers,
--     CASE 
--         WHEN total_providers < 300 THEN 'Low'
--         WHEN total_providers BETWEEN 300 AND 400 THEN 'Medium'
--         ELSE 'High'
--     END AS provider_density_class
-- FROM providers_population_summary;

// show this table
SELECT * FROM zip_provider_classification LIMIT 50;

