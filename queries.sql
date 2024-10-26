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
-- p3_1 --
SELECT 
    loc.entity,
    loc.code,
    AVG(dc.number_rabies) AS avg_number_rabies,
    MIN(dc.number_rabies) AS min_number_rabies,
    MAX(dc.number_rabies) AS max_number_rabies,
    SUM(dc.number_rabies) AS sum_number_rabies
FROM 
    pandemic.disease_cases dc
JOIN 
    pandemic.locations loc ON dc.location_id = loc.location_id
WHERE 
    dc.number_rabies IS NOT NULL
GROUP BY 
    loc.entity, loc.code;

-- p3_2 --
SELECT 
    loc.entity,
    loc.code,
    AVG(dc.number_rabies) AS avg_number_rabies,
    MIN(dc.number_rabies) AS min_number_rabies,
    MAX(dc.number_rabies) AS max_number_rabies,
    SUM(dc.number_rabies) AS sum_number_rabies
FROM 
    pandemic.disease_cases dc
JOIN 
    pandemic.locations loc ON dc.location_id = loc.location_id
WHERE 
    dc.number_rabies IS NOT NULL
GROUP BY 
    loc.entity, loc.code
ORDER BY 
    avg_number_rabies DESC;

-- p3_3 --
SELECT 
    loc.entity,
    loc.code,
    AVG(dc.number_rabies) AS avg_number_rabies,
    MIN(dc.number_rabies) AS min_number_rabies,
    MAX(dc.number_rabies) AS max_number_rabies,
    SUM(dc.number_rabies) AS sum_number_rabies
FROM 
    pandemic.disease_cases dc
JOIN 
    pandemic.locations loc ON dc.location_id = loc.location_id
WHERE 
    dc.number_rabies IS NOT NULL
GROUP BY 
    loc.entity, loc.code
ORDER BY 
    avg_number_rabies DESC
LIMIT 10;


-- p4 -- ********************************************************************
SELECT 
    year,
    DATE(CONCAT(year, '-01-01')) AS first_january,      -- Атрибут з датою 1 січня відповідного року
    CURDATE() AS current_day,                           -- Атрибут з поточною датою
    YEAR(CURDATE()) - year AS years_diff                -- Атрибут з різницею в роках між current_day та first_january
FROM 
    pandemic.disease_cases;

-- p5 -- ********************************************************************
DELIMITER //

CREATE FUNCTION year_difference(input_year INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE first_january DATE;
    DECLARE years_diff INT;
    
    -- Створюємо дату на 1 січня відповідного року
    SET first_january = DATE(CONCAT(input_year, '-01-01'));
    
    -- Обчислюємо різницю в роках між поточною датою і 1 січня input_year
    SET years_diff = YEAR(CURDATE()) - YEAR(first_january);
    
    RETURN years_diff;
END //

DELIMITER ;

SELECT
    year,
    year_difference(year) AS years_diff
FROM
    pandemic.disease_cases;
