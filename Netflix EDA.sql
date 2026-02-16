SELECT * FROM mydata


SELECT
	type,
	COUNT(*) AS count
FROM mydata
GROUP BY type
ORDER BY count DESC;

WITH director_norm as(
	SELECT
		TRIM(directors) as directors
	FROM mydata,
	UNNEST(STRING_TO_ARRAY(director, ',')) as directors
	WHERE director != 'Not Given'
)
SELECT 
	directors,
	COUNT(*) AS count
FROM director_norm
GROUP BY directors
ORDER BY count DESC
LIMIT 5;



WITH tdn as(
	SELECT
		show_id,
		title,
		type,
		TRIM(directors) as directors
	FROM mydata,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS directors
	WHERE director != 'Not Given'
)
SELECT 
	title,
	type,
	COUNT(*) as count_directors
FROM tdn
GROUP BY title, type
ORDER BY count_directors DESC;

-- Movies vs TV Shows over time

SELECT 
	year,
	type,
	count,
	CONCAT(ROUND((count / total_shows *100),2), '%') AS percentage
FROM(
	SELECT
		EXTRACT(YEAR FROM date_added) AS year,
		type,
		COUNT(*) AS count,
		SUM(COUNT(*)) OVER(PARTITION BY EXTRACT(YEAR FROM date_added)) AS total_shows
	FROM mydata
	GROUP BY type, year
	ORDER BY year) sub


-- Release Year vs Date Added (Content Age)
-- Average Content Age
-- Median Content Age
-- Create bucket lists for new realeases Vs. Catalog
SELECT 
	ROUND(AVG(content_age),0) as average_content_age,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY content_age)
FROM(
	SELECT 
		title,
		release_year,
		EXTRACT( YEAR FROM date_added) AS Year_added,
		EXTRACT( YEAR FROM date_added) - release_year AS content_age
	FROM mydata
	ORDER BY content_age DESC)sub

WITH binned_data AS(
SELECT
	type,
	CASE 
		 WHEN content_age >= 0 AND content_age <= 1 THEN '0 - 1 (New Release)'
		 WHEN content_age >=2 AND content_age <= 5 THEN '2 - 5'
		 WHEN content_age >= 6 AND content_age <= 10 THEN '6 - 10'
		 WHEN content_age > 10 THEN '10+years (Catalog)'
	END as age_buckets
FROM(
	SELECT
		show_id,
		type,
		title,
		release_year,
		EXTRACT( YEAR FROM date_added) AS Year_added,
		EXTRACT( YEAR FROM date_added) - release_year AS content_age
	FROM mydata
	ORDER BY content_age DESC
	)sub
WHERE content_age >= 0
	)
SELECT
	type,
	age_buckets,
	COUNT(*) AS total_count,
	ROUND(100* COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY type), 2) AS Contribution
FROM binned_data
GROUP BY age_buckets, type
ORDER BY type, total_count

-- 2️⃣Audience & Market Targeting
-- Ratings distribution (TV-MA, PG-13, etc.)


SELECT
	type,
	rating,
	COUNT(*) AS Shows_Distribution,
	ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY type), 2) as Contributuion
FROM mydata
GROUP BY type, rating
ORDER BY type asc, Shows_Distribution DESC

-- Country-wise content production
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS Countries,
	COUNT(*) AS shows_Distribution
FROM mydata
WHERE country != 'Not Given'
GROUP BY Countries
ORDER BY shows_Distribution DESC
LIMIT 20;

-- Genre analysis (Listed in)
SELECT
	type,
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS Genres,
	COUNT(*) AS shows_Distribution
FROM mydata
GROUP BY type, Genres
ORDER BY type, shows_Distribution DESC

-- 3️⃣ Operational & Production Complexity
-- Cast size analysis
-- outliers
WITH actors as(
SELECT
	title,
	type,
	COUNT(actor) as actor_count
FROM(
	SELECT
		show_id,
		title,
		type,
		TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS actor
	FROM mydata) SUB
GROUP BY title,type
ORDER BY actor_count DESC
)
SELECT 
	MIN(actor_count) MINIMUM,
	MAX(actor_count) MAXIMUM,
	ROUND(AVG(actor_count),2) AVERAGE,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY actor_count) AS MEDIAN,
	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY actor_count) AS PERCENTILE_80
FROM actors
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- distribution
WITH actors as(
SELECT
	title,
	COUNT(*) AS actor_count,
	type,
	CASE 
		 WHEN COUNT(*) >= 1 AND COUNT(*) <= 3 THEN '1 - 3'
		 WHEN COUNT(*) >= 4 AND COUNT(*) <= 7 THEN '4 - 7'
		 WHEN COUNT(*) > 7  THEN '8+'
		 END AS cast_memmbers
FROM(
	SELECT
		show_id,
		title,
		type,
		TRIM(UNNEST(STRING_TO_ARRAY("cast", ','))) AS actor
	FROM mydata) SUB
GROUP BY title,type
ORDER BY actor_count DESC
)
SELECT 
	type,
	cast_memmbers,
	COUNT(*) AS total_count,
	ROUND((100 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY type)),2) as Contribution
FROM actors
GROUP BY type, cast_memmbers
ORDER BY type ,total_count DESC

-- Director productivity vs specialization
-- Does Netflix work with specialists or diversified directors?
WITH specialization_count as(
	SELECT
		directors,
		"Has Movie",
		"Has TV Show",
		CASE WHEN "Has Movie" = 1 AND "Has TV Show" = 1 THEN 'Both'
			 WHEN "Has Movie" = 1 AND "Has TV Show" = 0 THEN 'Movie-only'
			 WHEN "Has Movie" = 0 AND "Has TV Show" = 1 THEN 'TV-only'
			 ELSE 'ignore' END AS specialization
	FROM(
	SELECT 
		TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS directors,
		MAX(CASE WHEN type = 'Movie' THEN 1 Else 0 END) as "Has Movie",
		MAX(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) as "Has TV Show"
	FROM mydata
	WHERE director != 'Not Given'
	GROUP BY directors
	ORDER BY "Has Movie" DESC, "Has TV Show" DESC ) sub
	)
SELECT 
	specialization,
	COUNT(DISTINCT(directors)) as directors_count
FROM specialization_count
GROUP BY specialization
ORDER BY directors_count DESC
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
WITH specialization_count as(
	SELECT
		directors,
		title_count,
		CASE WHEN "Has Movie" = 1 AND "Has TV Show" = 1 THEN 'Both'
			 WHEN "Has Movie" = 1 AND "Has TV Show" = 0 THEN 'Movie-only'
			 WHEN "Has Movie" = 0 AND "Has TV Show" = 1 THEN 'TV-only'
			 ELSE 'ignore' END AS specialization
	FROM(
	SELECT 
		TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS directors,
		MAX(CASE WHEN type = 'Movie' THEN 1 Else 0 END) as "Has Movie",
		MAX(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) as "Has TV Show",
		COUNT(*) as title_count
	FROM mydata
	WHERE director != 'Not Given'
	GROUP BY directors
	) sub
	)
SELECT 
	specialization,
	COUNT(DISTINCT(directors)) as directors_count,
	ROUND(AVG(title_count), 2) as avg_titles_per_director
FROM specialization_count
GROUP BY specialization
ORDER BY directors_count DESC

-- 4️⃣Duration & Format Patterns
-- Movie duration distribution

ALTER TABLE mydata
ALTER COLUMN duration TYPE Varchar(100)

	SELECT 
		CASE WHEN durations <= 90 THEN '≤90'
			 WHEN durations > 90 AND durations <= 120 THEN '91-120'
			 WHEN durations > 120 THEN '120+'
			 END as duration_bucket,
		MIN(durations) as Minimum,
		MAX(durations) as Maximum,
		ROUND(AVG(durations), 2) as average,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY durations) as median,
		COUNT(*) as movies_duration_distribution
	FROM (
		SELECT
			TRIM(duration, 'min')::NUMERIC as durations
		FROM mydata
		WHERE type = 'Movie') sub
	GROUP BY duration_bucket
	ORDER BY average

-- TV show season analysis
WITH tv_seasons_percentage as(
	SELECT 
		CASE WHEN tv_seasons = 1 THEN  '1 season'
			 WHEN tv_seasons >1 AND tv_seasons <= 3 THEN '2-3 seasons'
			 WHEN tv_seasons >= 4 THEN '4+ seasons'
			 END as tv_buckets,
		COUNT(*) AS tv_seasons_distribution
	FROM(
		SELECT 
			TRIM(duration, 'Seasons')::NUMERIC as tv_seasons
		FROM mydata
		WHERE type = 'TV Show') tv_sub
	GROUP BY tv_buckets
)
SELECT 
	tv_buckets,
	tv_seasons_distribution,
	ROUND(100 * tv_seasons_distribution / SUM(tv_seasons_distribution) OVER() ,2)  as percentage
FROM tv_seasons_percentage
ORDER BY percentage

-- 5️⃣Textual Insight (Advanced but High Value)
-- Description keyword analysis

WITH word_token as(
	SELECT 
		type,
		rating,
		LOWER(UNNEST(STRING_TO_ARRAY(REGEXP_REPLACE(description, '[^a-zA-Z\s]', '', 'g'), ' '))) as word
	FROM mydata
),
filtered_words AS (
	SELECT
		type,
		rating,
		word
	FROM word_token
	WHERE word NOT IN ('the', 'and','than', 'must', 'while', 'them', 'where', 
					   'this', 'when', 'after','into', 'with', 'for', 'from', 
					    'their', 'that', 'his', 'her', 'she', 'him', 'they')
	AND length(word) > 3
)
SELECT 
	type,
	rating,
	word AS theme,
	COUNT(*) AS frequency
FROM filtered_words
GROUP BY type,rating,  word
HAVING COUNT(*) > 10 
ORDER BY rating, frequency DESC 

-- 6️⃣Data Quality Checks 
-- Missing data analysis

SELECT
	FLOOR(release_year / 10) * 10 AS decade,
	ROUND(100 * COUNT(*) FILTER (WHERE director = 'Not Given') / COUNT(*), 2) AS director_missing_pct,
	ROUND(100 * COUNT(*) FILTER (WHERE "cast" = 'Not Given') / COUNT(*), 2) AS cast_missing_pct,
	ROUND(100 * COUNT(*) FILTER (WHERE country = 'Not Given') / COUNT(*), 2) AS country_missing_pct
FROM mydata
WHERE release_year IS NOT NULL
GROUP BY decade
ORDER BY decade;



