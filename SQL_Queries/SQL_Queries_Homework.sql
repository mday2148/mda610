/*
Retrieve data from the MySQL sample database sakila to answer the questions below. For each question, store the SQL query you used and the answer in a text file (that can be edited in Sublime Text 3). Refer to the table structure when you answer the questions.

i. What are the names of all the languages in the database? Sort the languages alphabetically.
ii. Return the full names (first and last) of all actors with "BER" in their last name. Sort the returned names by their first name. (Hint: use the CONCAT() function to add two or more strings together.)
iii. How many last names are not repeated in the actor table?
iv. How many films involve a "Crocodile" and a "Shark"?
v. Return the full names of the actors who played in a film involving a "Crocodile" and a "Shark", along with the release year of the movie, sorted by the actors' last names.
vi. Find all the film categories in which there are between 40 and 60 films. Return the names of these categories and the number of films in each category, sorted in descending order of the number of films.
vii. Return the full names of all the actors whose first name is the same as the first name of the actor with ID 24.
viii. Return the full name of the actor who has appeared in the most films. (Hint: use the ORDER BY and LIMIT clauses.)
ix. Return the film categories with an average movie length longer than the average length of all movies in the sakila database.
x. Return the total sales of each store.

*/



USE sakila;

SELECT 
    name
FROM
    language
ORDER BY (name) ASC;

/* Answer i
'English'
'French'
'German'
'Italian'
'Japanese'
'Mandarin'
*/

SELECT 
    CONCAT(first_name, ' ', last_name)
FROM
    actor
WHERE
    last_name LIKE '%BER%'
ORDER BY (first_name) ASC;

/* Answer ii
'CHRISTOPHER BERRY'
'DARYL WAHLBERG'
'HENRY BERRY'
'KARL BERRY'
'LIZA BERGMAN'
'NICK WAHLBERG'
'PARKER GOLDBERG'
'VIVIEN BERGEN'
*/

SELECT 
    COUNT(DISTINCT (last_name))
FROM
    actor;

/* Answer iii
121 - this is the number of distinct names. They want the number of people who have a unique name.

/* Problem iii */
SELECT COUNT(last_name) AS num_names
FROM (SELECT last_name
      FROM actor
      GROUP BY last_name
      HAVING COUNT(last_name) = 1) not_repeated_names; 

+-----------+
| num_names |
+-----------+
|        66 |
+-----------+


*/

SELECT 
    COUNT(film_id)
FROM
    film
WHERE
    description LIKE '%Crocodile%'
        AND description LIKE '%Shark%';

/* Answer iv
10
*/


SELECT 
    CONCAT(first_name, ' ', last_name) AS fullname,
    f.release_year
FROM
    film_actor fa
        JOIN
    actor a ON fa.actor_id = a.actor_id
        JOIN
    film f ON f.film_id = fa.film_id
WHERE
    f.film_id IN (SELECT 
            f.film_id
        FROM
            film f
        WHERE
            f.description LIKE '%Crocodile%'
                AND f.description LIKE '%Shark%')
ORDER BY last_name;

more simple answer because you're creating a table that has all the information, you don't need to do a subquery first:
SELECT CONCAT(first_name, ' ', last_name) AS name, release_year 
FROM actor JOIN film_actor f_a
ON actor.actor_id = f_a.actor_id
JOIN film 
ON f_a.film_id = film.film_id
WHERE description LIKE '%Crocodile%'
AND description LIKE '%Shark%'
ORDER BY last_name;


/* Answer v
# fullname, release_year
KIRSTEN AKROYD, 2006
KIM ALLEN, 2006
AUDREY BAILEY, 2006
JULIA BARRYMORE, 2006
VIVIEN BASINGER, 2006
VIVIEN BERGEN, 2006
KARL BERRY, 2006
HENRY BERRY, 2006
KARL BERRY, 2006
LAURA BRODY, 2006
ZERO CAGE, 2006
JOHNNY CAGE, 2006
JON CHASE, 2006
FRED COSTNER, 2006
FRED COSTNER, 2006
JENNIFER DAVIS, 2006
SUSAN DAVIS, 2006
GINA DEGENERES, 2006
JULIANNE DENCH, 2006
ROCK DUKAKIS, 2006
AL GARLAND, 2006
HUMPHREY GARLAND, 2006
EWAN GOODING, 2006
PENELOPE GUINESS, 2006
WILLIAM HACKMAN, 2006
MEG HAWKE, 2006
WOODY HOFFMAN, 2006
MORGAN HOPKINS, 2006
JANE JACKMAN, 2006
ALBERT JOHANSSON, 2006
RAY JOHANSSON, 2006
ALBERT JOHANSSON, 2006
RAY JOHANSSON, 2006
MILLA KEITEL, 2006
FAY KILMER, 2006
MATTHEW LEIGH, 2006
GENE MCKELLEN, 2006
GRACE MOSTEL, 2006
GRACE MOSTEL, 2006
CHRISTIAN NEESON, 2006
ALBERT NOLTE, 2006
JAYNE NOLTE, 2006
KENNETH PALTROW, 2006
KIRSTEN PALTROW, 2006
SANDRA PECK, 2006
PENELOPE PINKETT, 2006
CAMERON STREEP, 2006
JOHN SUVARI, 2006
KENNETH TORN, 2006
HELEN VOIGHT, 2006
GROUCHO WILLIAMS, 2006
MORGAN WILLIAMS, 2006
GENE WILLIS, 2006
HUMPHREY WILLIS, 2006
WILL WILSON, 2006
UMA WOOD, 2006
FAY WOOD, 2006
MINNIE ZELLWEGER, 2006

*/


SELECT 
    COUNT(f.title) AS NumberofFilms, c.name AS Category
FROM
    film_category fc
        JOIN
    film f ON fc.film_id = f.film_id
        JOIN
    category c ON fc.category_id = c.category_id
GROUP BY Category
HAVING NumberofFilms BETWEEN 40 AND 60
ORDER BY NumberofFilms DESC;

/* Answer vi
# NumberofFilms, Category
60, Children
58, Comedy
57, Classics
57, Travel
56, Horror
51, Music
*/



SELECT 
    CONCAT(first_name, ' ', last_name)
FROM
    actor
WHERE
    first_name IN (SELECT 
            first_name
        FROM
            actor
        WHERE
            actor_id = 24)
;

/* Answer vii
# CONCAT(first_name," ", last_name)
CAMERON STREEP
CAMERON WRAY
CAMERON ZELLWEGER
*/

SELECT 
    CONCAT(a.first_name, ' ', a.last_name),
    COUNT(fa.actor_id) AS NumberofFilms
FROM
    film_actor fa
        JOIN
    actor a ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
ORDER BY NumberofFilms DESC
LIMIT 1
;

/* Answer viii
# CONCAT(a.first_name," ", a.last_name), NumberofFilms
GINA DEGENERES, 42
*/


SELECT 
    c.name AS category, AVG(length)
FROM
    film f
        JOIN
    film_category fc ON f.film_id = fc.film_id
        JOIN
    category c ON fc.category_id = c.category_id
GROUP BY category
HAVING AVG(length) > (SELECT 
        AVG(length)
    FROM
        film)
ORDER BY AVG(length) DESC;

/*
# category, AVG(length)
Sports, 128.2027
Games, 127.8361
Foreign, 121.6986
Drama, 120.8387
Comedy, 115.8276
*/


SELECT 
    c.store_id, SUM(p.amount) AS TotalSales
FROM
    customer c
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY c.store_id;

/* Answer x
# store_id, TotalSales
1, 37001.52
2, 30414.99
*/

