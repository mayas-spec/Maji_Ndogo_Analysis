-- Part 1
USE md_water_services;

SELECT *
FROM water_quality
LIMIT 5;

SELECT *
FROM employee;

SELECT *
FROM visits;

SELECT *
FROM data_dictionary;

-- Dive into the water source
SELECT *
FROM water_source;

SELECT DISTINCT type_of_water_source
FROM water_source;

SELECT *
FROM visits
WHERE time_in_queue > 500;

SELECT *
FROM water_quality
WHERE subjective_quality_score = 10 AND visit_count = 2;

SELECT *
FROM well_pollution
WHERE results = 'Clean' AND Biological > 0.01 AND description LIKE '%clean%';

UPDATE
   well_pollution_copy
SET
description = 'Bacteria: E. coli' WHERE
   description = 'Clean Bacteria: E. coli';
UPDATE
   well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia' WHERE
   description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
   well_pollution_copy
SET
results='Contaminated:Biological' WHERE
biological > 0.01 AND results = 'Clean';

UPDATE
    well_pollution_copy
SET
description = 'Bacteria: E. coli' WHERE
    description = 'Clean Bacteria: E. coli';
UPDATE
    well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia' WHERE
    description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
    well_pollution_copy
SET
results = 'Contaminated: Biological' WHERE
biological > 0.01 AND results = 'Clean'; DROP TABLE
    md_water_services.well_pollution_copy;