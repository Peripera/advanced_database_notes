
-- Lesson 1:  Select & FROM

-- Task 1

SELECT Title
FROM Movies;

-- Task 2 

SELECT Director
FROM Movies;

-- Task 3

SELECT Title, Director
FROM Movies;

-- Task 4

SELECT Title, Year
FROM Movies;

-- Task 5

SELECT *
FROM Movies;



-- Lesson 2: Queries with constraints

-- Task 1

SELECT Title
FROM Movies
WHERE id = 6;

-- Task 2

SELECT Title
FROM Movies
WHERE year BETWEEN 2000 AND 2010;

-- Task 3

SELECT Title
FROM Movies
WHERE year NOT BETWEEN 2000 AND 2010;

--Task 4

SELECT Title
FROM Movies
WHERE year NOT BETWEEN 2000 AND 2010;



-- Lesson 3: Queries with constraints PT 2

--  Task 1
SELECT Title 
FROM Movies
Where Title LIKE "%Toy%";

--  Task 2
SELECT Title, Director
FROM Movies
Where Director LIKE "John Lasseter";

--  Task 3
SELECT Title, Director
FROM Movies
Where Director NOT LIKE "John Lasseter";

--  Task 4
SELECT Title
FROM Movies
Where Title LIKE "%WALL-%";



-- Lesson 4: SQL Lesson 4: Filtering and sorting Query results 


--  Task 1
SELECT DISTINCT Director
FROM Movies
ORDER BY Director ASC;

--  Task 2
SELECT Title, Year
FROM Movies
ORDER BY year DESC
LIMIT 4;

--  Task 3
SELECT Title, Year
FROM Movies
ORDER BY Title ASC
LIMIT 5;

--  Task 4
SELECT Title, Year
FROM Movies
ORDER BY Title ASC
LIMIT 5 OFFSET 5;


-- Lesson 5: SQL Review: Simple SELECT Queries 

-- Task 1
SELECT Country, City, population
FROM north_american_cities
WHERE Country = "Canada";

-- Task 2
SELECT City
FROM north_american_cities
WHERE Country = "United States"
ORDER BY Latitude DESC;

-- Task 3
SELECT city, longitude
FROM north_american_cities
WHERE Longitude < -87.629798
ORDER BY Longitude;

-- Task 4
SELECT city, population
FROM north_american_cities
WHERE country = "Mexico"
ORDER BY Population DESC
LIMIT 2;

-- Task 5
SELECT city, population
FROM north_american_cities
WHERE country = "United States"
ORDER BY Population DESC
LIMIT 2 OFFSET 2;