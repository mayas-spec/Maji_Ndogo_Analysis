USE md_water_services;

-- cleaning our data

SELECT
	* 
FROM
	employee;
    
select 
	concat(LOWER(REPLACE(employee_name,"",".")),"@ndogowater.gov") AS email
FROM
	employee;
    
UPDATE employee
SET email = concat(LOWER(REPLACE(employee_name,"",".")),"@ndogowater.gov");

SET SQL_SAFE_UPDATES = 0;

select 
	length(TRIM(phone_number))
FROM
	employee;
    
UPDATE employee
SET phone_number = TRIM(phone_number);

select 
	*
FROM
	employee;
    
-- Honouring employees

SELECT 
	town_name,count(town_name)AS num_of_employees
FROM
	employee
GROUP BY town_name;

SELECT
	*
FROM
	visits;
    
SELECT
	assigned_employee_id, count(visit_count)AS num_of_visits
FROM
	visits
GROUP BY assigned_employee_id
order by num_of_visits desc
limit 3;

SELECT
	*
FROM
	employee
WHERE 
	assigned_employee_id IN (1,30,34);
    
-- Analyzing locations
select 
	province_name, town_name,location_type
from
	location;
    
select
	town_name,count(town_name)AS records_per_town
FROM
	location
group by town_name
order by records_per_town desc;

    
select
	province_name,count(province_name)AS records_per_province
FROM
	location
group by province_name
order by records_per_province desc;

SELECT
	province_name,town_name,count(town_name)AS records_per_town
from
	location
group by province_name,town_name
order by province_name,records_per_town desc;

SELECT
	location_type,count(location_type)AS records_per_type
FROM
	location
group by location_type;

SELECT 23740 / (15910 + 23740) * 100;

-- Diving into the sources
SELECT
	*
FROM
	water_source;
    
SELECT sum(number_of_people_served)AS total_num_served
FROM water_source;

SELECT
	type_of_water_source,count(source_id)AS num_of_sources
FROM water_source
group by type_of_water_source
order by num_of_sources desc;

select
	type_of_water_source,round(avg(number_of_people_served))AS avg_num_of_served
FROM
	water_source
group by type_of_water_source;

Select
	type_of_water_source,sum(number_of_people_served)AS total_people_served
FROM
	water_source
group by type_of_water_source
order by total_people_served desc;

Select
	type_of_water_source,round((sum(number_of_people_served)/27628140)*100)AS perct_people_served
FROM
	water_source
group by type_of_water_source
order by perct_people_served desc;

-- Start of a solution
Select
	type_of_water_source,
    sum(number_of_people_served)AS total_people_served,
    RANK() OVER(order by sum(number_of_people_served)DESC) AS ranka
FROM
	water_source
group by type_of_water_source
order by total_people_served desc;

Select
	source_id
	type_of_water_source,
    sum(number_of_people_served)AS total_people_served,
    RANK() OVER(order by sum(number_of_people_served)DESC) AS ranka
FROM
	water_source
WHERE type_of_water_source <> "tap_in_home"
group by source_id,type_of_water_source
order by total_people_served desc;

-- Analysing queues
SELECT
	*
FROM
	visits;
    
SELECT
	DATEDIFF(MAX(time_of_record),min(time_of_record))AS num_of_days
FROM
	visits;
    
SELECT
	ROUND(avg(nullif(time_in_queue,0)))
FROM
	visits;

SELECT
	dayname(time_of_record)AS day,
    ROUND(avg(nullif(time_in_queue,0))) AS avg_time_in_queue
FROM
	visits
GROUP BY day;

SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00')AS hour_0f_the_day,
    ROUND(avg(nullif(time_in_queue,0))) AS avg_time_in_queue
FROM
	visits
GROUP BY  hour_0f_the_day
order by avg_time_in_queue desc;

SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
	ROUND(AVG(CASE
		WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
END),
0)AS Sunday,
 ROUND(AVG(CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue 
ELSE NULL
END),
0) AS Monday,
 ROUND(AVG(CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue 
ELSE NULL
END),
0) AS Tuesday,
ROUND(AVG(CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue 
ELSE NULL
END),
0) AS Wednesday,
ROUND(AVG(CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue 
ELSE NULL
END),
0) AS Thursday,
ROUND(AVG(CASE
WHEN DAYNAME(time_of_record) = 'friday' THEN time_in_queue 
ELSE NULL
END),
0) AS friday,
ROUND(AVG(CASE
WHEN DAYNAME(time_of_record) = 'saturday' THEN time_in_queue 
ELSE NULL
END),
0) AS saturday
FROM
visits
WHERE
    time_in_queue != 0 
GROUP BY
hour_of_day
ORDER BY
    hour_of_day;

