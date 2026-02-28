-- LESSON 6: MULTI-TABLES WITH JOINS 

-- First task 

SELECT domestic_sales, international_sales, Title
FROM Boxoffice
LEFT JOIN Movies
    ON Movies.id = Boxoffice.movie_id;

-- Second task

SELECT Boxoffice.international_sales, Boxoffice.domestic_sales, Movies.Title
FROM Boxoffice 
INNER JOIN Movies
    ON movies.id = Boxoffice.movie_id
WHERE Boxoffice.domestic_sales < Boxoffice.International_sales;

-- Third task 

SELECT Movies.Title, Boxoffice.Rating 
FROM Movies
INNER JOIN Boxoffice
    ON Movies.id = Boxoffice.movie_id
ORDER BY Rating DESC;


-- LESSON 7: OUTER JOINS 

-- Fist task
SELECT DISTINCT Building
FROM Employees
LEFT JOIN Buildings
ON Building = Building_name

-- Second task
SELECT Building_name, capacity
FROM Buildings;

-- Third task
SELECT DISTINCT Building_name, Role
FROM Buildings
LEFT JOIN Employees
ON Building_name = Building ;


-- INTERVIEW QUESTION: FACEBOOK 

SELECT pages.page_id, page_likes.liked_date
FROM pages
LEFT JOIN page_likes
ON pages.page_id = page_likes.page_id
WHERE liked_date IS NULL
ORDER BY pages.page_id ASC;