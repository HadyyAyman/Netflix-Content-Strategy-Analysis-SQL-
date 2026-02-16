 
SELECT *
FROM mydata
LIMIT 20;
-- 1 COUNT NULL VALUES

/*
NETFLIX DATA 
Director / Cast / Country --> nulls are normal
Show_ID / Title / Type --> ARE NOT ACCEPTABLE
*/

SELECT 
	COUNT(*) FILTER(WHERE show_id IS NULL) AS Id_null,
	COUNT(*) FILTER(WHERE type IS NULL) AS type_null,
	COUNT(*) FILTER(WHERE title IS NULL) AS title_null,
	COUNT(*) FILTER(WHERE director IS NULL) AS director_null,
	COUNT(*) FILTER(WHERE "cast" IS NULL) AS cast_null,
	COUNT(*) FILTER(WHERE country IS NULL) AS country_null,
	COUNT(*) FILTER(WHERE date_added IS NULL) AS date_added_null,
	COUNT(*) FILTER(WHERE release_year IS NULL) AS release_year_null,
	COUNT(*) FILTER(WHERE rating IS NULL) AS rating_null,
	COUNT(*) FILTER(WHERE duration IS NULL) AS duration_null,
	COUNT(*) FILTER(WHERE listed_in IS NULL) AS listed_in_null,
	COUNT(*) FILTER(WHERE description IS NULL) AS description_null
FROM mydata;

/* 
SHOW_ID = NO NULLS
TITLE = NO NULLS
TYPE = NO NULLS
*/

-- 2 Finding DUPLICATES

SELECT show_id, COUNT(*)
FROM mydata
GROUP BY show_id
HAVING COUNT(*) > 1
-- No duplicates were found

-- IF THERE IS A SHOW HAVING THE SAME TITLE AND RELEASE YEAR
SELECT title, release_year, COUNT(*)
FROM mydata
GROUP BY title, release_year
HAVING COUNT(*) > 1


-- POPULATE DIRECTOR NULL VALUES ex: IS THERE A RELATION BETWEEN DIRECTOR AND CAST MEMMBER 

/* FIRST WE SPLIT THE CAST SO WE NORMALIZE IT  */
WITH cast_expanded AS (
	SELECT show_id, director, TRIM(actor) AS actor
	FROM mydata,
	UNNEST(STRING_TO_ARRAY("cast",',')) AS actor
	WHERE director IS NOT NULL
)
SELECT * 
FROM cast_expanded
LIMIT 10;

-- FIND ACTOR - DIRECTOR RELATIONSHIP
WITH cast_expanded AS (
	SELECT show_id, director, TRIM(actor) AS actor
	FROM mydata,
	UNNEST(STRING_TO_ARRAY("cast",',')) AS actor
	WHERE director IS NOT NULL
)
SELECT 
	TRIM(actor) AS actor,
	director,
	COUNT(*) AS collaborations
FROM cast_expanded
GROUP BY actor, director
HAVING COUNT(*) >= 3
ORDER BY collaborations DESC

-- TITLES WITH MISSING DIRECTORS AND THE RELATIONSHIP OF ACTOR/DIRECTOR PAIRS

WITH actor_director_pairs AS (
	SELECT 
		TRIM(actor) AS actor,
		director,
		COUNT(*) AS collaborations
	FROM mydata,
	UNNEST(STRING_TO_ARRAY("cast", ',')) AS actor
	WHERE director IS NOT NULL
	GROUP BY actor, director
	HAVING COUNT(*) >=3
),
missing_director_titles AS(
	SELECT 
		m.show_id,
		m.title,
		TRIM(actor) AS actor
	FROM mydata m,
	UNNEST(STRING_TO_ARRAY("cast", ',')) AS actor
	WHERE director IS NULL
)
SELECT 
	md.show_id,
	md.title,
	ad.director,
	ad.collaborations
FROM missing_director_titles md
JOIN actor_director_pairs ad
ON md.actor = ad.actor
ORDER BY collaborations DESC

/* 484 of the null value for directors can be populated because this query retrive the missing titles director
and suggest the director it should have based on the collaboration of the title cast with the suggested director
giving a fair chance that this title "MOVIE/TV-SHOW" was directed by that director */

-- NOW WE PRESERVE THE DATA IN A NEW COLUMN AND THEN ADD IT TO ORIGINAL COULMN 
ALTER TABLE mydata
ADD COLUMN pop_director TEXT;

WITH actor_director_pairs AS (
	SELECT 
		TRIM(actor) AS actor,
		director,
		COUNT(*) AS collaborations
	FROM mydata,
	UNNEST(STRING_TO_ARRAY("cast", ',')) AS actor
	WHERE director IS NOT NULL
	GROUP BY actor, director
	HAVING COUNT(*) >=3
),
missing_director_titles AS(
	SELECT 
		m.show_id,
		m.title,
		TRIM(actor) AS actor
	FROM mydata m,
	UNNEST(STRING_TO_ARRAY("cast", ',')) AS actor
	WHERE director IS NULL
)
UPDATE mydata m
SET pop_director = s.director
FROM (
		SELECT 
			md.show_id,
			ad.director
		FROM missing_director_titles md
		JOIN actor_director_pairs ad
		ON md.actor = ad.actor
)s
WHERE m.show_id = s.show_id

UPDATE mydata 
SET director = pop_director
WHERE pop_director IS NOT NULL

UPDATE mydata
SET director = 'Not Given'
WHERE director IS NULL

ALTER TABLE mydata 
DROP COLUMN pop_director

/* POPULATE THE COUNTRY COLUMN WITH DIRECTOR COLUMN*/
SELECT COALESCE(n1.country, n2.country)
FROM mydata n1
JOIN mydata n2
ON n1.director = n2.director
AND n1.show_id <> n2.show_id
WHERE n1.country IS NULL;

UPDATE mydata
SET country = n2.country
FROM mydata n2
WHERE mydata.director = n2.director and mydata.show_id <> n2.show_id
AND mydata.country IS NULL;

-- check if there is still some countries that are not populated
SELECT 
	director,
	country,
	date_added
FROM mydata
WHERE country IS NULL

-- populate the rest with not given
UPDATE mydata
SET country = 'Not Given'
WHERE country IS NULL 

-- populate the null values in cast with not given also
UPDATE mydata 
SET "cast" = 'Not Given'
WHERE "cast" IS NULL

SELECT * 
FROM mydata 
WHERE date_added IS NUll

-- deleting 10 rows of data_added nulls 10 of 8,000 will not affect the analysis 
DELETE FROM mydata 
WHERE show_id IN ('s7197','s6175','s6807','s7407', 's6067', 's6796', 's6902', 's7255', 's7848','s8183')
 
------------------------------------------------------------
-- CHECKING FOR INCONSISTENCIES BY GOING OVER EACH COLUMN 
SELECT DISTINCT type, COUNT(*)
FROM mydata
GROUP BY DISTINCT type

-- REMOVE ANY WHITE SPACES

UPDATE mydata
SET title = TRIM(title),
	director = TRIM(director),
	country = TRIM(country);
	
UPDATE mydata
SET rating = TRIM(rating),
	description = TRIM(description),
	"cast" = TRIM("cast"),
	listed_in = TRIM(listed_in);

-- CAPITALIZE THE FIRST LETTER FOR EVERY WORD 
UPDATE mydata
SET director = INITCAP(director),
	"cast" = INITCAP("cast"),
	country = INITCAP(country),
	listed_in = INITCAP(listed_in);

-- 4 NORMALIZE VALUES 

SELECT DISTINCT rating, COUNT(*)
FROM mydata
GROUP BY DISTINCT rating
ORDER BY COUNT(*) ASC

/* FIRST THREE VALUES ARE NOT RATING BUT DURATIONS BELONG TO THE DURATION COLUMN */
-- VALIDATING THAT THE DURATION VALUES FOR THESE VALUES ARE NULL
SELECT rating, duration
FROM mydata
where rating ~ '^[0-9]+ min$';

--TRANSFERING THE VALUES TO ITS ORIGINAL COLUMN
UPDATE mydata
SET duration = rating, rating = NULL
WHERE rating ~ '^[0-9]+ min$';

-- deleting 7 rows of reting nulls 7 of 8,000 will not affect the analysis 
SELECT show_id, rating
FROM mydata
WHERE rating IS NULL 

DELETE FROM mydata
WHERE show_id IN('s7313', 's6828', 's7538', 's5814', 's5795', 's5542', 's5990')

/* 5 ADJUSTING & CONVERTING DATA TYPES */
-- checking for any abnormalities in the release_year before changing its data type
SELECT DISTINCT release_year, COUNT(*)
From mydata
GROUP BY DISTINCT release_year

ALTER TABLE mydata
ALTER COLUMN release_year TYPE INT
USING release_year::INT;

-- CONVERT DATE_ADDED FROM TEXT TO DATE
-- THE FORMAT USED IS ex: APRIL 17, 2021 
-- THE PREFERED FORAMT IS YEAR-MONTH-DAY 
SELECT date_added
FROM mydata
WHERE date_added IS NOT NULL

ALTER TABLE mydata
ALTER COLUMN date_added TYPE DATE
USING TO_DATE(date_added, 'MONTH DD, YYYY')

ALTER TABLE mydata
ALTER COLUMN show_id TYPE VARCHAR(55)

ALTER TABLE mydata
ADD CONSTRAINT pk_show PRIMARY KEY (show_id);

ALTER TABLE mydata
ALTER COLUMN title SET NOT NULL;


-- SPLIT MULTI-VALUE COLUMNS 
SELECT show_id, 
	   TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
	   TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS directors,
	   TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS "cast",
	   TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country
FROM mydata

/* WITH cte AS
(
SELECT title, CONCAT(director, '---', "cast") AS director_cast 
FROM mydata
)

SELECT director_cast, COUNT(*) AS count
FROM cte
GROUP BY director_cast
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC; */


