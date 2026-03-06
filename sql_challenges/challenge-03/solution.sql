
-- LESSON 10: Queries with aggregates 

-- Task 1 
SELECT MAX(Years_employed) as max_years
FROM Employees;

-- Task 2
SELECT AVG(Years_employed) as max_years, role
FROM Employees
GROUP BY role;

-- Task 3
SELECT SUM(Years_employed) as max_years, Building
FROM Employees
GROUP BY Building;

--  Lesson 11: Queries with aggregates (Pt. 2) 

--Task 1
SELECT COUNT(Role)
FROM Employees
WHERE role = "Artist";

--Task 2
SELECT COUNT(*), Role
FROM Employees
GROUP BY Role;

-- Task 3
SELECT SUM(Years_employed), Role
FROM Employees
WHERE Role = 'Engineer';


-- Oracle Aggregate functions tutorial

-- Task 1

select COUNT ( unique shape) number_of_shapes,
       STDDEV (unique weight) distinct_weight_stddev
from   bricks;

-- Task 2
select shape, SUM(weight) as shape_weight
from   bricks
Group by shape
ORDER BY shape ASC;

-- Task 3
select shape, sum ( weight )
from   bricks
group  by Shape
Having sum(weight)< 4 ;
