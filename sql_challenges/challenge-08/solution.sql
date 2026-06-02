/* Exercise 1 - Find the slow query*/

SELECT * FROM patient_visits WHERE site_id = 3;

/*-- Questions:
-- a) What scan type do you see? Why?
I expect to see a full table scan. This happens because site_id 
only has values from 1 to 5. That means many rows have the same site_id. Oracle may think it is faster to read the whole table instead of using an index.


-- b) site_id has values 1–5. Is this high or low cardinality?
This is low cardinality.


-- c) Would adding an index on site_id help? Why or why not?
No, An index may not help because each value appears in many rows.

*/

/* Exercise 2 — Create an index and see if it helps*/

CREATE INDEX idx_pv_visit_date ON patient_visits(visit_date);

-- Gather stats --

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

-- Run Query --

SELECT * FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

/* Questions:
-- a) Does Oracle use the index for this range?
Yes, it may use the index if the date range returns a small part of the table.

-- b) Change the range to the last 7 days. Does the plan change?
For the last 7 days, Oracle is more likely to use the index. So fewer rows are returned.

-- c) Change to the last 700 days. What happens?
Oracle will not use the index and intead perform a full table scan.

-- d) Why does the range size affect whether Oracle uses the index?
The range size matters because Oracle chooses the quickest plan. For small number of rows
ranges return fewer rund among a considerable amount of data, but for bigger ranges, indexes will return many rows and 
that's a lot f informartion to read regarding the efiency of the system
*/

/**Exercise 3 Composite index*/

WHERE patient_id = 1234 AND visit_date > SYSDATE - 90

-- Composite index:
CREATE INDEX idx_pv_patient_date 
ON patient_visits(patient_id, visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

-- Query--
SELECT * FROM patient_visits
WHERE patient_id = 1234
  AND visit_date > SYSDATE - 90;

/* Questions:
-- a) Does the plan use the composite index?
-- Yes, Oracle uses the composite index because the query matches both columns in the same order as the index.

-- b) Now try querying ONLY on visit_date (no patient_id).

SELECT * FROM patient_visits 
WHERE visit_date > SYSDATE - 90;

The index starts with patient_id. If the query only uses visit_date, Oracle cannot easily use the index from the middle.

-- c) What's the rule about column order in composite indexes?
The first column is the most important.
*/

/* Exercise 4 - Function that breaks an index*/

-- This query CAN use the index:
SELECT * FROM patient_visits WHERE patient_id = 5432;

-- This one cannot — why?
SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';

-- Why the previouse query didn't use the index,a) what scan type did it use and b) why does warapping a column in a function 
--break index use?

/*a) What scan type did the second query use?

The second query probably used a full table scan.

b) Why does wrapping a column in a function break index use?

The index stores the normal value of patient_id.

When I write TO_CHAR(patient_id), Oracle has to change the value before comparing it. Because of that, the normal index on patient_id may not match the expression.

c) How would you rewrite the second query to allow index use?

I would write it without the function, to keeo patient as a number and use the index:*/

SELECT * FROM patient_visits WHERE patient_id = 5432;

/* Exercise 5 - Discussion: real-world scenarios

For each scenario, I need to decide three things:

a) Would I add an index?  
b) On which column or columns?  
c) What problems or concerns could happen? */



-- Scenario A --

-- A reporting table gets loaded once per night (batch ETL).
-- During the day, analysts run SELECT queries by date range.
-- The table has 50 million rows.
-- → Index on date? Yes/No, why?
-- a) Would you add an index? --

/*Yes, I would add an index.The table is very large, so searching by date range
without an index can be slow. Since analysts use SELECT
queries during the day and the table is only loaded once per night,
this is a good case for an index.
*/
-- b) On which column(s)?

/*I would add an index on the date column used in the date range queries.*/

-- c) Any concerns?

/*Yes. That the index uses extra storage and can make the nightly load slower 
because the database must update the index after loading data. Also, if the 
date range is too large, Oracle may still choose a full table scan.*/


-- Scenario B --

-- An OLTP orders table gets 10,000 inserts per minute.
-- Support staff look up orders by customer_id or order_status.
-- order_status has 4 values: pending, processing, shipped, cancelled.
-- → What indexes would you add?

--a) Would you add an index?

/*Yes, i would add an index for customer_id because it is likely to 
have many different values. This makes it useful for finding specific customer orders.*/


-- b) On which column(s)?

/*I would add an index on `customer_id`. If the most common searches use both customer_id and order_status together.*/

-- c) Any concerns?

/*Yes. The table gets 10,000 inserts per minute, so too many indexes can slow down inserts.
Every new row must also update the indexes. I would avoid adding unnecessary indexes, 
especially on low-cardinality columns like order_status.*/

---

-- Scenario C --

-- A patient table has an email column (unique per patient).
-- There are 5 million patients.
-- The app frequently does: WHERE email = 'user@example.com'
-- → What kind of index would be best here?

-- a) Would you add an index?

/*Yes, this is a very good case for an index because the table is large and the query searches 
for one exact value. Since each email is unique, Oracle can use the index to find one patient 
very fast.*/

-- b) On which column(s)?

/*I would add a unique index on the email column. A unique constraint on email would also 
be a good option because it protects the data and makes sure no two patients have the same email.*/

-- c) Any concerns?

/*Yes, the main concern is that emails should be stored in a consistent format, like lowercase. 
If the app uses functions to compare emails, a normal index may not work well. */