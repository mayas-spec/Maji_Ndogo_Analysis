-- Part 4
-- join location to visits
SELECT province_name,town_name,visit_count,v.location_id
FROM location AS l
JOIN visits AS v 
ON l.location_id = v.location_id;

-- join the water_source table on the key shared between water_source and visits.
SELECT province_name,town_name,visit_count,v.location_id,type_of_water_source,number_of_people_served
FROM location AS l
JOIN visits AS v 
ON l.location_id = v.location_id
JOIN water_source AS ws
ON v.source_id = ws.source_id;

-- Note that there are rows where visit_count > 1.
SELECT province_name,town_name,visit_count,v.location_id,type_of_water_source,number_of_people_served
FROM location AS l
JOIN visits AS v 
ON l.location_id = v.location_id
JOIN water_source AS ws
ON v.source_id = ws.source_id
WHERE v.location_id = 'AkHa00103';

-- select rows where visits.visit_count = 1
SELECT province_name,town_name,visit_count,v.location_id,type_of_water_source,number_of_people_served
FROM location AS l
JOIN visits AS v 
ON l.location_id = v.location_id
JOIN water_source AS ws
ON v.source_id = ws.source_id
WHERE v.visit_count = 1;

-- Ok, now that we verified that the table is joined correctly, we can remove the location_id and visit_count columns.
SELECT province_name,town_name,type_of_water_source,location_type,number_of_people_served,time_in_queue
FROM location AS l
JOIN visits AS v 
ON l.location_id = v.location_id
JOIN water_source AS ws
ON v.source_id = ws.source_id
WHERE v.visit_count = 1;

-- Last one! Now we need to grab the results from the well_pollution table.
SELECT
    water_source.type_of_water_source,
    location.town_name,
    location.province_name,
    location.location_type,
    water_source.number_of_people_served,
    visits.time_in_queue,
    well_pollution.results
FROM
visits
LEFT JOIN
    well_pollution
ON well_pollution.source_id = visits.source_id INNER JOIN
location
ON location.location_id = visits.location_id INNER JOIN
    water_source
ON water_source.source_id = visits.source_id WHERE
    visits.visit_count = 1;
    
CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis.select
select
water_source.type_of_water_source AS source_type, 
location.town_name,
location.province_name,
location.location_type, 
water_source.number_of_people_served AS people_served,
 visits.time_in_queue,well_pollution.results
FROM
visits
LEFT JOIN
    well_pollution
ON well_pollution.source_id = visits.source_id
 INNER JOIN location
ON location.location_id = visits.location_id 
INNER JOIN water_source
ON water_source.source_id = visits.source_id 
WHERE visits.visit_count = 1;

--  building another pivot table! 
WITH province_totals AS (-- This CTE calculates the population of each province
 SELECT
        province_name,
SUM(people_served) AS total_ppl_serv 
FROM
        combined_analysis_table
GROUP BY
        province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source. -- The results are aggregated and percentages are calculated 
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river, 
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap, 
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home, 
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken, 
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
    combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
    ct.province_name
ORDER BY
    ct.province_name;
    
WITH province_totals AS (-- This CTE calculates the population of each province
 SELECT
        province_name,
SUM(people_served) AS total_ppl_serv
FROM
        combined_analysis_table
GROUP BY
        province_name
)
SELECT * FROM province_totals;

WITH town_totals AS (
-- This CTE calculates the population of each town,Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river, ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap, ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home, ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken, ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
 GROUP BY -- We group by province first, then by town.
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;
    
-- Before we jump into the data, let's store it as a temporary table first, so it is quicker to access.
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
-- This CTE calculates the population of each town,Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river, ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap, ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home, ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken, ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
 GROUP BY -- We group by province first, then by town.
    ct.province_name,
    ct.town_name
ORDER BY
    ct.town_name;
    
-- which town has the highest ratio of people who have taps, but have no running water?
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
    town_aggregated_water_access;
    
-- We need to know if the repair is complete, and the date it was completed, and give them space to upgrade the sources. Let's call this table Project_progress.
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE, Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')), Date_of_completion DATE,
Comments TEXT
);

-- −− Project_progress_query
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id;

-- lets start with the WHERE section:
SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND (results!= 'clean' -- AND one of the following (OR) options must be true as well.
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
);

-- Step 1: Wells Let's start with wells. Depending on whether they are chemically contaminated, or biologically contaminated — we'll decide on the interventions.
SELECT 
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
results,
CASE WHEN results = 'contaminated:Biological' THEN 'Install UV filter'
	WHEN results = 'chemical' THEN 'Install RO filter'
		ELSE NULL
END AS improvement
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND (results!= 'clean' -- AND one of the following (OR) options must be true as well.
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
);

-- Add Drill well to the Improvements column for all river sources.
SELECT 
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
results,
CASE WHEN results = 'contaminated:Biological' THEN 'Install UV filter'
	WHEN results = 'chemical' THEN 'Install RO filter'
    WHEN type_of_water_source = 'river' THEN 'Drill Well'
		ELSE NULL
END AS improvement
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND (results!= 'clean' -- AND one of the following (OR) options must be true as well.
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
);

-- Next up, shared taps. We need to install one tap near each shared tap for every 30 min of queue time.
SELECT 
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
results,
CASE WHEN results = 'contaminated:Biological' THEN 'Install UV filter'
	WHEN results = 'chemical' THEN 'Install RO filter'
    WHEN type_of_water_source = 'river' THEN 'Drill Well'
    WHEN type_of_water_source = 'shared_tap' and (time_in_queue >= 30) 
    THEN CONCAT("Install ", FLOOR(time_in_queue/30), " tap(s) nearby")
		ELSE NULL
END AS improvement
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND (results!= 'clean' -- AND one of the following (OR) options must be true as well.
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
);


-- Add a case statement to our query updating broken taps to Diagnose local infrastructure.
select 
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
results,
CASE WHEN results = 'contaminated:Biological' THEN 'Install UV filter'
	WHEN results = 'chemical' THEN 'Install RO filter'
    WHEN type_of_water_source = 'river' THEN 'Drill Well'
    WHEN type_of_water_source = 'shared_tap' and (time_in_queue >= 30) 
    THEN CONCAT("Install ", FLOOR(time_in_queue/30), " tap(s) nearby")
    WHEN type_of_water_source = 'tap_in_home_broken'THEN 'iagnose local infrastructure'
		ELSE NULL
END AS improvement
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND (results!= 'clean' -- AND one of the following (OR) options must be true as well.
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
);

-- Add the data to Project_progress
CREATE TEMPORARY TABLE Project_report AS
select 
location.address AS Address,
location.town_name AS Town,
location.province_name AS Province,
water_source.source_id,
water_source.type_of_water_source AS Source_type,
results,
CASE WHEN results = 'contaminated:Biological' THEN 'Install UV filter'
	WHEN results = 'chemical' THEN 'Install RO filter'
    WHEN type_of_water_source = 'river' THEN 'Drill Well'
    WHEN type_of_water_source = 'shared_tap' and (time_in_queue >= 30) 
    THEN CONCAT("Install ", FLOOR(time_in_queue/30), " tap(s) nearby")
    WHEN type_of_water_source = 'tap_in_home_broken'THEN 'iagnose local infrastructure'
		ELSE NULL
END AS improvement
FROM
    water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND (results!= 'clean' -- AND one of the following (OR) options must be true as well.
OR type_of_water_source IN ('tap_in_home_broken','river') 
OR (type_of_water_source = 'shared_tap' AND (time_in_queue >= 30))
);

-- Insert into Project_progress
INSERT INTO Project_progress(source_id,Address,Town,Province,Source_type,Improvement)
SELECT source_id,Address,Town,Province,Source_type,Improvement
FROM Project_report
