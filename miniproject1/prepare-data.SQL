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

---- Update and resolve ------
---- Update and resolve ------

WITH borrowed_info AS (
 SELECT
  f.title AS film_title,
  a.first_name || ' ' || a.last_name AS actor_fullname,
  c.name AS category,
  l.name AS language,
  cs.first_name || ' ' || cs.last_name AS customer_fullname,
  a2.address AS customer_address,
  s.first_name || ' ' || s.last_name AS staff_fullname,
  a1.address AS store_address,
  date(r.rental_date) AS rental_date,
  COALESCE(date(r.return_date), 'forgot') AS return_date,
  CASE
     WHEN r.return_date IS NOT NULL THEN
        (julianday(date(r.return_date)) - julianday(date(r.rental_date)))
     ELSE
        (julianday(date('2007-01-01')) - julianday(date(r.rental_date)))
  	 END AS number_borrowed_days
FROM film AS f
LEFT JOIN film_actor AS fa ON f.film_id = fa.film_id
JOIN actor AS a ON fa.actor_id = a.actor_id
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
JOIN language AS l ON f.language_id = l.language_id
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON i.inventory_id = r.inventory_id
JOIN customer AS cs ON r.customer_id = cs.customer_id
JOIN address AS a2 ON cs.address_id = a2.address_id
JOIN staff AS s ON r.staff_id = s.staff_id
JOIN store AS st ON s.store_id = st.store_id
JOIN address AS a1 ON st.address_id = a1.address_id
ORDER BY film_title
),
late_fines AS 
  (
  SELECT ROW_NUMBER () OVER (ORDER BY film_title) AS list,
  *, 
	ROUND(number_borrowed_days *1.23,3) AS late_fines_dollar
    FROM borrowed_info
ORDER BY late_fines_dollar DESC
LIMIT 10
  )

SELECT 
SUM (late_fines_dollar),
AVG (late_fines_dollar),
MAX (late_fines_dollar),
MIN (late_fines_dollar)
FROM late_fines;

