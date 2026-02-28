# Session 17-02-2026

This second season we will practice SQL JOINS and case of use, using SQLBolt, the following challenges are from section 6 and section 7 respectively.
Also we did an easy interview question from Facebook in Data Lemur. That will be explained down below.


## Section 6: Multi-table queries with JOINs

We've added a new table to the Pixar database so that you can try practicing some joins. The BoxOffice table stores information about the ratings and sales of each particular Pixar movie, and the Movie_id column in that table corresponds with the Id column in the Movies table 1-to-1. Try and solve the tasks below using the INNER JOIN introduced above.


+ Find the domestic and international sales for each movie
+ Show the sales numbers for each movie that did better internationally rather than domestically
+ List all the movies by their ratings in descending order


## Section 7: OUTER JOINS

In this exercise, you are going to be working with a new table which stores fictional data about Employees in the film studio and their assigned office Buildings. Some of the buildings are new, so they don't have any employees in them yet, but we need to find some information about them regardless.

Since our browser SQL database is somewhat limited, only the LEFT JOIN is supported in the exercise below.



- Find the list of all buildings that have employees
- Find the list of all buildings and their capacity
- List all buildings and the distinct employee roles in each building (including empty buildings)


## Interview question from Data Lemur 

Assume you're given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").
Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.