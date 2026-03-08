
--Analytic Functions: Databases for Developers

-- Task 1

select b.*,
       count(*) over (
         partition by Shape
       ) bricks_per_shape,
       median ( weight ) over (
         partition by Shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;


-- Task 2

select b.brick_id, b.weight,
       round ( avg ( weight ) over ( -- redondear el promedio del peso de la primera fila por brick id de la primera a la ultima                                
         order by brick_id
       ), 2 ) running_average_weight -- Declara atributo ruuning_average_weight para observar los resultadOs  
from   bricks b
order  by brick_id;

--Task 3

select b.*,
       min ( colour ) over (
         order by brick_id
         rows between 2 preceding and 1 preceding
       ) first_colour_two_prev,
       count (*) over (
         order by weight
         range between 1 preceding and 1 following
       ) count_values_this_and_next
from   bricks b
order  by weight;

-- Task 4}

with totals as (
  select b.*,
         sum ( weight ) over (
           partition by shape)
         weight_per_shape,
         sum ( weight ) over (
           ORDER BY brick_id)
        running_weight_by_id
  from   bricks b
)
select * from totals
where  weight_per_shape > 4 AND running_weight_by_id > 4
order  by brick_id

-- Data lemur FAANG question

SELECT
  D.department_name,
  E.name,
  E.salary
FROM (
  SELECT 
    name,
    salary,
    department_id,
    DENSE_RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
  FROM 
    employee
  ) AS e
JOIN
  department AS D
ON
  E.department_id = D.department_id
WHERE
  salary_rank <= 3
ORDER BY 
  department_name ASC,
  salary DESC,
  name ASC-,

