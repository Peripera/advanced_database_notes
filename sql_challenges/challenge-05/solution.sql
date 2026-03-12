-- Task 1 --

select colour from my_brick_collection
Union
select colour from your_brick_collection
order by colour;


-- Task 1.2 --

select shape from my_brick_collection
Union all 
select shape from your_brick_collection
order  by shape;


-- Task 2 --

select shape from my_brick_collection
minus
select shape from your_brick_collection;


-- Task 1.2

select colour from my_brick_collection
Intersect
select colour from your_brick_collection
order  by colour;



