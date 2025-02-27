-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT country, COUNT(*) AS movie_count
FROM (
    SELECT TRIM(value) AS country
    FROM netflix, 
    JSON_TABLE(
        CONCAT('["', REPLACE(country, ', ', '","'), '"]'),
        "$[*]" COLUMNS (value VARCHAR(255) PATH "$")
    ) AS split_countries
) AS country_list
GROUP BY country
ORDER BY movie_count DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT * from netflix
WHERE str_to_date(trim(date_added), '%M %e, %Y') >= date_sub((curdate()), interval 5 year);
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT*
FROM netflix
WHERE director like "%Rajiv Chilaka%"; 
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT listed_in, COUNT(*) AS movie_count
FROM (
    SELECT TRIM(value) AS listed_in
    FROM netflix, 
    JSON_TABLE(
        CONCAT('["', REPLACE(listed_in, ', ', '","'), '"]'),
        "$[*]" COLUMNS (value VARCHAR(255) PATH "$")
    ) AS split_genre
) AS genre_list
GROUP BY listed_in;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
   (year(str_to_date(trim(date_added), '%M %e, %Y'))) as content_released_year, 
   count(*) as yearly_content, 
   round(((count(*)/(select count(*) from mytable where country like "%India%"))*100),2) as Avg_content_per_year_pct
FROM netflix
WHERE country like "%India%"
GROUP BY content_released_year
ORDER BY content_released_year desc;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= year(Curdate()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT  cast, COUNT(*) AS movie_count
FROM (
    SELECT TRIM(value) AS cast
    FROM netflix, 
    JSON_TABLE(
        CONCAT('["', REPLACE(cast, ', ', '","'), '"]'),
        "$[*]" COLUMNS (value VARCHAR(1000) PATH "$")
    ) AS split_cast
    where country like "%India%"
) AS cast_list
GROUP BY cast
ORDER BY movie_count DESC;
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
