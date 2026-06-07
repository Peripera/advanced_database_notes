

#### Q1: What are the limitations of DBMS_METADATA vs expdp?

DBMS_METADATA is useful because it can show the SQL code to recreate database objects.
But it mostly gives DDL, not the real table data.
It also needs more manual work because I have to copy or save the output myself.
expdp is stronger because it can export both structure and data, but it needs more permissions.

#### Q2: If you have circular dependencies, how would you handle the reload?

I would create the basic objects first and add the relationships later.
For example, I would create the tables first without worrying too much about foreign keys.
Then I would add or enable the constraints after the tables exist.

#### Q3: Your company is migrating from one Oracle database to another. What is your plan?

First, I would check what objects exist in the old schema.
Then I would use DBMS_METADATA to export the DDL.
After that, I would remove old schema names and check foreign keys.
Then I would run the scripts in the new database in the correct order.
At the end, I would compare the objects and test some queries to make sure it worked.