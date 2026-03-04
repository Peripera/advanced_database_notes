
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
       ), 2 ) running_average_weight -- Declara atributo ruuning_average_weight para obvservar los resultadps  
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



