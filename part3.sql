-- Part 3

SELECT * FROM md_water_services.auditor_report;
SELECT location_id,true_water_source_score
FROM auditor_report;

 -- join the visits table to the auditor_report table. Make sure to grab subjective_quality_score, record_id and location_id.
select
auditor_report.location_id AS audit_location, 
auditor_report.true_water_source_score, 
visits.location_id AS visit_location,
 visits.record_id
FROM
    auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id;

-- JOIN the visits table and the water_quality table, using the record_id as the connecting key.
select
auditor_report.location_id AS audit_location, 
auditor_report.true_water_source_score, 
visits.location_id AS visit_location,
 visits.record_id,
 subjective_quality_score
FROM
    auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id;

-- It doesn't matter if your columns are in a different format, because we are about to clean this up a bit. Since it is a duplicate, we can drop one of the location_id columns.
SELECT
auditor_report.location_id AS location_id,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id;

-- A good starting point is to check if the auditor's and exployees' scores agree.
SELECT
auditor_report.location_id AS location_id,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
WHERE auditor_report.true_water_source_score = water_quality.subjective_quality_score;

-- you got 2505 rows right? Some of the locations were visited multiple times, so these records are duplicated here. To fix it, we set visits.visit_count = 1 in the WHERE clause. Make sure you reference the alias you used for visits in the join.
SELECT
auditor_report.location_id AS location_id,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score = water_quality.subjective_quality_score;

-- With the duplicates removed I now get 1518. What does this mean considering the auditor visited 1620 sites?
SELECT
auditor_report.location_id AS location_id,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score;

-- we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.
SELECT
auditor_report.location_id AS location_id,
auditor_report.type_of_water_source AS auditor_source,
water_source.type_of_water_source AS surveyor_source,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score;

-- Once you're done, remove the columns and JOIN statement for water_sources again.
SELECT
auditor_report.location_id AS location_id,
auditor_report.type_of_water_source AS auditor_source,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score;

-- Linking records to employees
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score;

WITH Incorrect_records AS(
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score
)
SELECT*
FROM Incorrect_records;

-- unique list of employees
WITH Incorrect_records AS(
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score
)
SELECT distinct employee_name 
FROM Incorrect_records;

-- nu,mber of mistakes
WITH Incorrect_records AS(
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score
)
SELECT distinct employee_name ,
count(employee_name)AS number_of_mistakes
FROM Incorrect_records
group by employee_name; 

-- Gathering some evidence
SELECT DISTINCT employee_name,
       COUNT(employee_name) AS number_of_mistakes
FROM (
    SELECT
        auditor_report.location_id AS location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.true_water_source_score AS auditor_score,
        water_quality.subjective_quality_score AS surveyor_score
    FROM
        auditor_report
    JOIN
        visits
    ON
        auditor_report.location_id = visits.location_id
    JOIN
        water_quality
    ON
        visits.record_id = water_quality.record_id
    JOIN
        employee
    ON
        visits.assigned_employee_id = employee.assigned_employee_id
    WHERE 
        visits.visit_count = 1
        AND auditor_report.true_water_source_score != water_quality.subjective_quality_score
) AS Incorrect_records
GROUP BY employee_name;


-- average
WITH error_count AS(
SELECT distinct employee_name ,
count(employee_name)AS number_of_mistakes
FROM(
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score
) AS Incorrect_records
group by employee_name
)
SELECT avg(number_of_mistakes)AS avg_error_count_per_employee
FROM error_count;

-- suspect list
WITH error_count AS(
SELECT distinct employee_name ,
count(employee_name)AS number_of_mistakes
FROM(
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score
) AS Incorrect_records
group by employee_name
)
SELECT 
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT avg(number_of_mistakes)AS avg_error_count_per_employee
FROM error_count);

CREATE view incorrect_records AS(
select
auditor_report.location_id AS location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS surveyor_score,
auditor_report.statements AS statements
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN
employee
ON visits.assigned_employee_id = employee.assigned_employee_id
WHERE visits.visit_count = 1 AND
auditor_report.true_water_source_score != water_quality.subjective_quality_score);

SELECT *
FROM Incorrect_records;

-- suspect list to CTE


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made 
SELECT
        employee_name,
COUNT(employee_name) AS number_of_mistakes FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database for records where the auditor and
employees scores are different*/
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
        employee_name,
        number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
 SELECT
    employee_name,
    location_id,
    statements
FROM
    Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list);


DROP VIEW IF EXISTS incorrect_records;

CREATE VIEW incorrect_records AS
SELECT
    auditor_report.location_id AS location_id,
    visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.statements AS statements
FROM
    auditor_report
JOIN
    visits
ON 
    auditor_report.location_id = visits.location_id
JOIN
    water_quality
ON 
    visits.record_id = water_quality.record_id
JOIN
    employee
ON 
    visits.assigned_employee_id = employee.assigned_employee_id
WHERE 
    visits.visit_count = 1 
    AND auditor_report.true_water_source_score != water_quality.subjective_quality_score;
    
-- Filter records that refer to cash
WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
where number_of_mistakes > (select avg(number_of_mistakes)as avg_error_count_per_employee FROM error_count
)
)
SELECT
    employee_name,
    location_id,
    statements
FROM
    Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list)
AND statements like "%cash%";

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM (
        SELECT
            auditor_report.location_id AS location_id,
            visits.record_id,
            employee.employee_name,
            auditor_report.true_water_source_score AS auditor_score,
            water_quality.subjective_quality_score AS surveyor_score
        FROM
            auditor_report
        JOIN
            visits
        ON
            auditor_report.location_id = visits.location_id
        JOIN
            water_quality
        ON
            visits.record_id = water_quality.record_id
        JOIN
            employee
        ON
            visits.assigned_employee_id = employee.assigned_employee_id
        WHERE
            visits.visit_count = 1
            AND auditor_report.true_water_source_score != water_quality.subjective_quality_score
    ) AS Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT
        employee_name,
        number_of_mistakes
    FROM
        error_count
    WHERE
        number_of_mistakes > (
            SELECT AVG(number_of_mistakes)
            FROM error_count
        )
)
SELECT
    ir.employee_name,
    ir.location_id,
    ir.statements
FROM (
    SELECT
        auditor_report.location_id AS location_id,
        visits.record_id,
        employee.employee_name,
        auditor_report.statements
    FROM
        auditor_report
    JOIN
        visits
    ON
        auditor_report.location_id = visits.location_id
    JOIN
        water_quality
    ON
        visits.record_id = water_quality.record_id
    JOIN
        employee
    ON
        visits.assigned_employee_id = employee.assigned_employee_id
    WHERE
        visits.visit_count = 1
) AS ir
WHERE
    ir.employee_name IN (SELECT employee_name FROM suspect_list)
    AND ir.statements LIKE '%cash%';

SELECT*
FROM Incorrect_records
where statements like "%cash%"


    
