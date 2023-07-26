.open sqlite-sakila.db
.print 'MOVIE_INFORMATION'
.mode box
.header on
WITH movie_info AS (
  SELECT
  f.title,
  a.first_name || " " || last_name AS fullname,
  CASE
  WHEN c.name IS NULL THEN 'not specified'
  WHEN c.name = 'New' THEN 'News'
  ELSE c.name
  END AS category,
  COALESCE(l.name, 'not specified', 'Unknown') AS language
FROM actor AS a
JOIN film AS f
ON a.actor_id = f.film_id
LEFT JOIN category AS c
ON f.film_id = c.category_id
LEFT JOIN language AS l
ON f.film_id = l.language_id
GROUP BY title
  )
SELECT 
  ROW_NUMBER () OVER (ORDER BY title) AS list,
  * 
  FROM movie_info LIMIT 10;

.print "CUSTOMER INFORMATION"
WITH cs_info AS (
SELECT 
    cs.first_name || " " || cs.last_name AS customer_name,
    address.address,
    cs.active,
    date(ren.rental_date) AS rental_date,
    COALESCE(date(ren.return_date), 'forgot') AS return_date,
    CASE
      WHEN ren.return_date IS NOT NULL THEN
        (julianday(date(ren.return_date)) - julianday(date(ren.rental_date)))
      ELSE
        (julianday(date('now')) - julianday(date(ren.rental_date)))
    END AS borrowed_days
  FROM customer AS cs
  JOIN address 
    ON cs.address_id = address.address_id
  JOIN rental AS ren
    ON cs.customer_id = ren.customer_id
  ORDER BY borrowed_days
)

SELECT 
  *,
  ROUND((borrowed_days * 0.99), 3) AS late_fines
FROM cs_info LIMIT 10;

.print "STAFF_INFORMATION"
WITH staff_info AS (
SELECT first_name || " " || last_name AS staff_fullname,
  address.address AS store_address
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN staff 
ON store.manager_staff_id = staff.staff_id
)

SELECT *
FROM staff_info;


.print "OVERDUE_LIST"
WITH movie_info AS (
  SELECT
  f.title,
  a.first_name || " " || last_name AS fullname,
  CASE
  WHEN c.name IS NULL THEN 'not specified'
  WHEN c.name = 'New' THEN 'News'
  ELSE c.name
  END AS category,
  COALESCE(l.name, 'not specified', 'Unknown') AS language
FROM actor AS a
JOIN film AS f
ON a.actor_id = f.film_id
LEFT JOIN category AS c
ON f.film_id = c.category_id
LEFT JOIN language AS l
ON f.film_id = l.language_id
GROUP BY title
  ),
 cs_info AS (
SELECT 
    cs.first_name || " " || cs.last_name AS customer_name,
    address.address,
    cs.active,
    date(ren.rental_date) AS rental_date,
    COALESCE(date(ren.return_date), 'forgot') AS return_date,
    CASE
      WHEN ren.return_date IS NOT NULL THEN
        (julianday(date(ren.return_date)) - julianday(date(ren.rental_date)))
      ELSE
        (julianday(date('now')) - julianday(date(ren.rental_date)))
    END AS borrowed_days
  FROM customer AS cs
  JOIN address 
    ON cs.address_id = address.address_id
  JOIN rental AS ren
    ON cs.customer_id = ren.customer_id
  ORDER BY borrowed_days
),
 staff_info AS (
SELECT first_name || " " || last_name AS staff_fullname,
  address.address AS store_address
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN staff 
ON store.manager_staff_id = staff.staff_id
)
  
SELECT
  cs_info.customer_name,
  cs_info.address AS customer_address,
  movie_info.title AS movie_name,
  movie_info.fullname AS lead_actor,
  movie_info.category,
  movie_info.language,
  staff_info.staff_fullname,
  staff_info.store_address,
  cs_info.rental_date,
  cs_info.return_date,
  cs_info.borrowed_days,
  ROUND((borrowed_days * 0.99), 3) AS late_fines_dollar
FROM movie_info
CROSS JOIN cs_info
CROSS JOIN staff_info
ORDER BY late_fines_dollar DESC
LIMIT 10
