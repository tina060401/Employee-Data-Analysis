CREATE DATABASE HRDATA;

USE HRDATA;

SELECT * FROM hr;

-- CLEANING AND PRE-PROCESSING

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END
WHERE birthdate IS NOT NULL;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = 
    CASE 
        WHEN termdate IS NOT NULL AND termdate != '' 
        THEN DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
        ELSE NULL
    END
WHERE 
    termdate IS NOT NULL AND termdate != '' AND termdate != '0000-00-00';
SELECT * FROM hr WHERE termdate = '' OR termdate = '0000-00-00';


-- SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
-- WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*) FROM hr WHERE age < 18;

SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();

SELECT COUNT(*)
FROM hr
WHERE termdate = '0000-00-00';

-- ANALYSIS 

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM hr
WHERE gender IS NOT NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM hr
WHERE race IS NOT NULL
GROUP BY race
ORDER BY count(*) DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
 min(age) AS Youngest,
 max(age) AS Oldest
FROM hr
WHERE age>=18;

SELECT
 CASE
  WHEN age>=18 AND age<=24 THEN '18-24'
  WHEN age>=25 AND age<=32 THEN '25-32'
  WHEN age>=33 AND age<=40 THEN '33-40'
  WHEN age>=41 AND age<=46 THEN '41-46'
  WHEN age>=47 AND age<=51 THEN '47-51'
  WHEN age>=52 AND age<=58 THEN '52-58'
  else '59+'
 END AS age_group,
 count(*) AS count
FROM hr
GROUP BY age_group
ORDER BY age_group;

-- 4. How many employees work at headquarters vs remote?
SELECT location, count(*) AS count
FROM hr
GROUP BY location;

-- 5. How does the gender distribution vary across the departments and job titles?
SELECT department, gender, count(*) AS Count
FROM hr
GROUP BY department, gender
ORDER BY department;

-- 6. What is the distribution of job titles across the company?
SELECT jobtitle, count(*) AS Count
FROM hr
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 7. What is the distribution of employees across the country?
SELECT location_state, count(*) AS Count
FROM hr
GROUP BY location_state
ORDER BY Count DESC;