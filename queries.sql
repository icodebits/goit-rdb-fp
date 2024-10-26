-- p1 -- ********************************************************************
-- Створення схеми pandemic
CREATE SCHEMA pandemic;

-- Використання схеми pandemic за замовчуванням
USE pandemic;

-- p2 -- ********************************************************************
-- Створення таблиці locations
CREATE TABLE pandemic.locations (
    location_id SERIAL PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code CHAR(10) NOT NULL
);

-- Заповнення таблиці locations
INSERT INTO pandemic.locations (entity, code)
SELECT DISTINCT Entity, Code
FROM pandemic.infectious_cases;

-- Створення таблиці disease_cases із зовнішнім ключеми location_id
CREATE TABLE pandemic.disease_cases (
    case_id SERIAL PRIMARY KEY,
    location_id BIGINT UNSIGNED REFERENCES pandemic.locations(location_id),
    year INT NOT NULL,
    number_yaws FLOAT,
    polio_cases FLOAT,
    cases_guinea_worm FLOAT,
    number_rabies FLOAT,
    number_malaria FLOAT,
    number_hiv FLOAT,
    number_tuberculosis FLOAT,
    number_smallpox FLOAT,
    number_cholera_cases FLOAT
);

-- Оновлення таблиці infectious_cases щоб позбутись пустих значень
UPDATE pandemic.infectious_cases
SET 
    Number_yaws = NULLIF(Number_yaws, ''),
    polio_cases = NULLIF(polio_cases, ''),
    cases_guinea_worm = NULLIF(cases_guinea_worm, ''),
    Number_rabies = NULLIF(Number_rabies, ''),
    Number_malaria = NULLIF(Number_malaria, ''),
    Number_hiv = NULLIF(Number_hiv, ''),
    Number_tuberculosis = NULLIF(Number_tuberculosis, ''),
    Number_smallpox = NULLIF(Number_smallpox, ''),
    Number_cholera_cases = NULLIF(Number_cholera_cases, '');


-- Заповнення таблиці disease_cases нормалізованими даними зв'язаними по ключу location_id
INSERT INTO pandemic.disease_cases (
    location_id, year, number_yaws, polio_cases, cases_guinea_worm, 
    number_rabies, number_malaria, number_hiv, 
    number_tuberculosis, number_smallpox, number_cholera_cases
)
SELECT 
    loc.location_id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM pandemic.infectious_cases ic
JOIN pandemic.locations loc ON ic.Entity = loc.entity AND ic.Code = loc.code;


-- p3 -- ********************************************************************


-- p4 -- ********************************************************************


-- p5 -- ********************************************************************
