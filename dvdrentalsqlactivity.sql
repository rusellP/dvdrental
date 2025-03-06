-- ITE 16
-- Members: Rusell G. Pernito, Princess Eyre Bonghanoy, Mary Adrianne D. Bisoy 

-- 1. List of Films Rented by Customers in Santiago, Alphabetically
SELECT DISTINCT f.title
FROM film f, rental r, customer c, address a, city ci
WHERE f.film_id = r.inventory_id
  AND r.customer_id = c.customer_id
  AND c.address_id = a.address_id
  AND a.city_id = ci.city_id
  AND ci.city = 'Santiago'
ORDER BY f.title;

-- 2. The Least Rented Categories of Films in Aurora City
SELECT c.name, COUNT(r.rental_id) AS rental_count
FROM category c, film_category fc, film f, rental r, inventory i, store s, address a, city ci
WHERE c.category_id = fc.category_id
  AND fc.film_id = f.film_id
  AND f.film_id = i.film_id
  AND i.inventory_id = r.inventory_id
  AND i.store_id = s.store_id
  AND s.address_id = a.address_id
  AND a.city_id = ci.city_id
  AND ci.city = 'Aurora'
GROUP BY c.name
ORDER BY rental_count ASC
LIMIT 1;

-- 3. Top 5 Most Commonly Rented Films in Baku and Aurora City
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f, rental r, inventory i, store s, address a, city ci
WHERE f.film_id = i.film_id
  AND i.inventory_id = r.inventory_id
  AND i.store_id = s.store_id
  AND s.address_id = a.address_id
  AND a.city_id = ci.city_id
  AND (ci.city = 'Baku' OR ci.city = 'Aurora')
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 5;

-- 4. Customers Who Rented Films Without Rental Fees
SELECT c.first_name, c.last_name, f.title, f.rental_rate
FROM customer c, rental r, inventory i, film f
WHERE c.customer_id = r.customer_id
  AND r.inventory_id = i.inventory_id
  AND i.film_id = f.film_id
  AND r.rental_id NOT IN (SELECT rental_id FROM payment);

-- 5. Penalties Collected by Each Store
SELECT s.store_id, SUM(p.amount) AS total_penalty
FROM store s, rental r, inventory i, film f, payment p
WHERE s.store_id = i.store_id
  AND i.inventory_id = r.inventory_id
  AND i.film_id = f.film_id
  AND r.rental_id = p.rental_id
  AND r.return_date > (r.rental_date + INTERVAL '1 day' * f.rental_duration)
GROUP BY s.store_id;

-- 6. Customers Who Have Rented Films from All Categories
SELECT DISTINCT c.first_name, c.last_name
FROM customer c, rental r, inventory i, film_category fc, category cat
WHERE c.customer_id = r.customer_id
  AND r.inventory_id = i.inventory_id
  AND i.film_id = fc.film_id
  AND fc.category_id = cat.category_id
  AND (SELECT COUNT(DISTINCT cat2.category_id) FROM category cat2) = (SELECT COUNT(DISTINCT cat3.category_id) 
                                                                      FROM category cat3, film_category fc3, rental r3, inventory i3, customer c3
                                                                      WHERE c3.customer_id = r3.customer_id 
                                                                        AND r3.inventory_id = i3.inventory_id
                                                                        AND i3.film_id = fc3.film_id 
                                                                        AND fc3.category_id = cat3.category_id 
                                                                        AND c.customer_id = c3.customer_id);

-- 7. Average Rental Duration for Films with Replacement Cost Greater than $20.00 Rented More than 5 Times
SELECT AVG(f.rental_duration) AS avg_rental_duration
FROM film f, rental r, inventory i
WHERE f.film_id = i.film_id
  AND i.inventory_id = r.inventory_id
  AND f.replacement_cost > 20.00
  AND (SELECT COUNT(r2.rental_id) FROM rental r2 WHERE r2.inventory_id = i.inventory_id) > 5;

-- 8. Films Rented by Customers Who Live in the Same City as the Staff Member Who Processed the Rental
SELECT DISTINCT f.title
FROM film f, rental r, inventory i, customer c, address a, city ci, staff s, address sa, city sci
WHERE f.film_id = i.film_id
  AND i.inventory_id = r.inventory_id
  AND r.customer_id = c.customer_id
  AND c.address_id = a.address_id
  AND a.city_id = ci.city_id
  AND r.staff_id = s.staff_id
  AND s.address_id = sa.address_id
  AND sa.city_id = sci.city_id
  AND ci.city = sci.city;

-- 9. Films with the Highest and Lowest Rental Rates within Each Category
SELECT c.name, f1.title AS highest_rate_film, f1.rental_rate AS highest_rate, f2.title AS lowest_rate_film, f2.rental_rate AS lowest_rate
FROM category c, film_category fc1, film f1, film_category fc2, film f2
WHERE c.category_id = fc1.category_id
  AND fc1.film_id = f1.film_id
  AND c.category_id = fc2.category_id
  AND fc2.film_id = f2.film_id
  AND f1.rental_rate = (SELECT MAX(f3.rental_rate)
                        FROM film f3, film_category fc3
                        WHERE fc3.category_id = c.category_id
                          AND fc3.film_id = f3.film_id)
  AND f2.rental_rate = (SELECT MIN(f4.rental_rate)
                        FROM film f4, film_category fc4
                        WHERE fc4.category_id = c.category_id
                          AND fc4.film_id = f4.film_id);
