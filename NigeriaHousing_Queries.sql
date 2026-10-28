SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT state) AS states,
       COUNT(DISTINCT town)  AS towns
FROM dbo.houses_raw;

CREATE OR ALTER VIEW dbo.houses AS
WITH cleaned AS (
    SELECT CAST(CAST(bedrooms      AS FLOAT) AS INT)    AS bedrooms,
           CAST(CAST(bathrooms     AS FLOAT) AS INT)    AS bathrooms,
           CAST(CAST(toilets       AS FLOAT) AS INT)    AS toilets,
           CAST(CAST(parking_space AS FLOAT) AS INT)    AS parking_space,
           LTRIM(RTRIM(title))                          AS house_type,
           LTRIM(RTRIM(town))                           AS town,
           CASE WHEN LTRIM(RTRIM(state)) = 'Anambara'
                THEN 'Anambra' ELSE LTRIM(RTRIM(state)) END AS state,
           CAST(CAST(price AS FLOAT) AS BIGINT)         AS price
    FROM dbo.houses_raw
    WHERE CAST(price AS FLOAT) BETWEEN 5000000 AND 2000000000
),
numbered AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY bedrooms, bathrooms, toilets, parking_space,
                            house_type, town, state, price
               ORDER BY (SELECT NULL)) AS copy_no
    FROM cleaned
)
SELECT bedrooms, bathrooms, toilets, parking_space,
       house_type, town, state, price,
       CASE WHEN copy_no = 1 THEN 1 ELSE 0 END AS is_first_copy
FROM numbered;
GO

-- check
SELECT COUNT(*)           AS rows_kept,
       SUM(is_first_copy) AS distinct_listings,
       MIN(price)         AS cheapest,
       MAX(price)         AS most_expensive,
       SUM(CASE WHEN state = 'Anambra' THEN 1 ELSE 0 END) AS anambra_rows
FROM dbo.houses;

---
WITH s AS (
    SELECT DISTINCT
           state,
           COUNT(*) OVER (PARTITION BY state) AS listings,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY state)      AS median_price
    FROM dbo.houses
    WHERE is_first_copy = 1
)
SELECT state,
       listings,
       CAST(median_price / 1000000.0 AS DECIMAL(10,1)) AS median_price_millions
FROM s
WHERE listings >= 30
ORDER BY median_price DESC;

---
WITH t AS (
    SELECT DISTINCT
           town,
           COUNT(*) OVER (PARTITION BY town) AS listings,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY town) AS median_price,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price * 1.0 / NULLIF(bedrooms, 0))
               OVER (PARTITION BY town) AS median_price_per_bedroom
    FROM dbo.houses
    WHERE is_first_copy = 1
      AND state = 'Lagos'
)
SELECT town,
       listings,
       CAST(median_price / 1000000.0 AS DECIMAL(10,1))             AS median_price_millions,
       CAST(median_price_per_bedroom / 1000000.0 AS DECIMAL(10,1)) AS price_per_bedroom_millions
FROM t
WHERE listings >= 30
ORDER BY median_price DESC;

---
WITH t AS (
    SELECT DISTINCT
           house_type,
           COUNT(*) OVER (PARTITION BY house_type) AS listings,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY house_type)      AS median_price,
           AVG(bedrooms * 1.0) OVER (PARTITION BY house_type) AS avg_bedrooms
    FROM dbo.houses
    WHERE is_first_copy = 1
      AND state = 'Lagos'
)
SELECT house_type,
       listings,
       CAST(median_price / 1000000.0 AS DECIMAL(10,1)) AS median_price_millions,
       CAST(avg_bedrooms AS DECIMAL(4,1))              AS avg_bedrooms
FROM t
ORDER BY median_price DESC;

--
WITH t AS (
    SELECT DISTINCT
           house_type,
           COUNT(*) OVER (PARTITION BY house_type) AS listings,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY house_type)      AS median_price
    FROM dbo.houses
    WHERE is_first_copy = 1
      AND state = 'Lagos'
      AND town = 'Lekki'
      AND bedrooms = 4
)
SELECT house_type,
       listings,
       CAST(median_price / 1000000.0 AS DECIMAL(10,1)) AS median_price_millions
FROM t
WHERE listings >= 30
ORDER BY median_price DESC;

--
WITH t AS (
    SELECT DISTINCT
           bedrooms,
           COUNT(*) OVER (PARTITION BY bedrooms) AS listings,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY bedrooms)      AS median_price
    FROM dbo.houses
    WHERE is_first_copy = 1
      AND state = 'Lagos'
)
SELECT bedrooms,
       listings,
       CAST(median_price / 1000000.0 AS DECIMAL(10,1)) AS median_price_millions
FROM t
WHERE listings >= 30
ORDER BY bedrooms;

--
WITH a AS (
    SELECT DISTINCT town,
           COUNT(*) OVER (PARTITION BY town) AS listings_all,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY town)      AS median_all
    FROM dbo.houses
    WHERE state = 'Lagos'
),
d AS (
    SELECT DISTINCT town,
           COUNT(*) OVER (PARTITION BY town) AS listings_distinct,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price)
               OVER (PARTITION BY town)      AS median_distinct
    FROM dbo.houses
    WHERE state = 'Lagos' AND is_first_copy = 1
)
SELECT d.town,
       a.listings_all,
       d.listings_distinct,
       CAST(a.median_all      / 1000000.0 AS DECIMAL(10,1)) AS median_all_millions,
       CAST(d.median_distinct / 1000000.0 AS DECIMAL(10,1)) AS median_distinct_millions
FROM d
JOIN a ON a.town = d.town
WHERE d.listings_distinct >= 30
ORDER BY d.median_distinct DESC;

--
CREATE OR ALTER VIEW dbo.houses_distinct AS
SELECT state,
       town,
       house_type,
       bedrooms,
       bathrooms,
       toilets,
       parking_space,
       price,
       price / 1000000.0                          AS price_millions,
       price / 1000000.0 / NULLIF(bedrooms, 0)    AS price_per_bedroom_millions
FROM dbo.houses
WHERE is_first_copy = 1;
GO

-- check: should return 13707 rows and 25 states
SELECT COUNT(*) AS listings, COUNT(DISTINCT state) AS states
FROM dbo.houses_distinct;