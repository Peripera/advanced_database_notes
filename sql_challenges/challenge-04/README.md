# Challenge 4

## Analytic Functions: Databases for Developers

An introduction to analytic functions.

### Instructions
 
- Complete the following query to return the count and average weight of bricks for each shape:
- Complete the following query to get the running average weight, ordered by brick_id
- Complete the windowing clauses to return:

    * The minimum colour of the two rows before (but not including) the current row
    * The count of rows with the same weight as the current and one value following


- Complete the following query to find the rows where

    * The total weight for the shape
    * The running weight by brick_id

*are both greater than four:*

### DATA LEMUR QUESTION

As part of an ongoing analysis of salary distribution within the company, your manager has requested a report identifying high earners in each department. A 'high earner' within a department is defined as an employee with a salary ranking among the top three salaries within that department.

You're tasked with identifying these high earners across all departments. Write a query to display the employee's name along with their department name and salary. In case of duplicates, sort the results of department name in ascending order, then by salary in descending order. If multiple employees have the same salary, then order them alphabetically.

Note: Ensure to utilize the appropriate ranking window function to handle duplicate salaries effectively.

As of June 18th, we have removed the requirement for unique salaries and revised the sorting order for the results.