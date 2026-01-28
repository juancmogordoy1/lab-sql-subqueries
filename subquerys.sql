USE sakila;

-- la subconsulta busca el film_id de la película. Luego,
-- la consulta externa cuenta cuántas veces aparece ese ID en el inventario.
SELECT 
COUNT(inventory_id) AS total_copies
FROM inventory
WHERE film_id = (
    SELECT film_id 
    FROM film 
    WHERE title = 'Hunchback Impossible'
);

-- calculamos el promedio primero en la subconsulta y lo comparamos con cada película
SELECT title, length
FROM film
WHERE length > (
    SELECT AVG(length) 
    FROM film
);

-- usamos subconsultas anidadas. La más interna busca el ID de la película,
-- la intermedia busca los IDs de los actores que salen en ella, y la externa nos da sus nombres.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id = (
        SELECT film_id 
        FROM film 
        WHERE title = 'Alone Trip'
    )
);

-- bonus Family
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_category
    WHERE category_id = (
        SELECT category_id 
        FROM category 
        WHERE name = 'Family'
    )
);

-- join vs sbquery
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id FROM address WHERE city_id IN (
        SELECT city_id FROM city WHERE country_id = (
            SELECT country_id FROM country WHERE country = 'Canada'
        )
    )
);

SELECT cu.first_name, cu.last_name, cu.email
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- actor mas prolifico
SELECT title
FROM film
JOIN film_actor USING (film_id)
WHERE actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

-- pelis mas rentables
SELECT DISTINCT title
FROM film
JOIN inventory USING (film_id)
JOIN rental USING (inventory_id)
WHERE customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- clientes q gastaron mas q el promedio
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_per_customer)
    FROM (
        SELECT SUM(amount) AS total_per_customer
        FROM payment
        GROUP BY customer_id
    ) AS subquery
);





