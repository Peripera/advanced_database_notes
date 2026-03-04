
## Examples of use

### PARTITION BY

 - *OVER (PARTITION BY colour) crea “grupos virtuales” por color sin colapsar filas (a diferencia de GROUP BY). Entonces, cada fila sigue existiendo, pero además le “pegan” agregados calculados sobre todas las filas de su mismo color.*

select b.*,  // Seleccionamos toda la tabla renombrada como b (*Te trae todas las columnas de la fila actual*)
       count(*) over () total_count // Contamos todo sobre la tabla brinks, *Cuanta todos los items y los muestra en cada fila*
from   bricks b; // De la tabla briks *Agregamos el alias de la tabla*


### ORDER BY EXAMPLE


* 1
select colour, count(*), sum ( weight ) // Contamos del atributo de colores todos los elementos y hacemos una suma de los pesos
from   bricks 
group  by colour; // *Agrupamos por color y nos da una tabla con la suma de los obejtos y otro atributo comn la suma de los pesos de cada uno* Por lo que hace una pariticion de ambos grupos del mismo valor


* 2
select b.*,  //*Trae todas las col de la fila actual*
       count(*) over ( //* para esa fila cuenta*
         partition by colour //*cuantas filas existen en briks*
       ) bricks_per_colour,  //* con el mismo color*
       sum ( weight ) over ( // *Sumamos los pesos de las filas*
         partition by colour // *contados por color*
       ) weight_per_colour
from   bricks b;

* 3

SELECT * FROM (
    SELECT name, salary, DEPARTMENT_ID, max (salary) over (PARTITION by DEPARTMENT_ID)
    FROM Employee) Employee
    WHERE e.saary = e.max_salary

* 4

SELECT name, salary,
row_number() over (ORDER BY Salary) as row_number,
rank() over(ORDER BY Salary) as rank,
dense_rank() over(ORDER BY Salary) as dense_rank
FROM Employee


### PARTITION BY + ORDER BY 

Se puede combina ambas funciones para sacar el total de una particion 

