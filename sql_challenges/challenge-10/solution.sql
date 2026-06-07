-- Lesson 05: Schema Backup & Restore
-- Solution file

-- Exercise 1: Explore schema objects

SELECT object_type, COUNT(*) AS cnt
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

SELECT object_name, object_type, created, last_ddl_time
FROM user_objects
ORDER BY object_type, object_name;


-- Exercise 2: Basic GET_DDL

BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
ORDER BY table_name;


-- Exercise 3: Clean DDL for portability

BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
WHERE ROWNUM = 1;


-- Exercise 4: Plan a migration

SELECT constraint_name, table_name, r_constraint_name
FROM user_constraints
WHERE constraint_type = 'R';

-- Replace SALE_ITEM with a real table that has foreign keys in your schema.
SELECT DBMS_METADATA.GET_DDL('TABLE', 'SALE_ITEM')
FROM DUAL;


-- Exercise 5: Dependency order

SELECT referenced_name, name, type
FROM user_dependencies
ORDER BY referenced_name;

SELECT name, type
FROM user_dependencies
WHERE referenced_name IN (
  SELECT table_name FROM user_tables
)
ORDER BY type, name;


-- Exercise 6: SQL-only backup strategy

SELECT object_type, COUNT(*) 
FROM user_objects 
GROUP BY object_type;

SELECT table_name, num_rows 
FROM user_tables 
ORDER BY num_rows DESC;

SELECT DBMS_METADATA.GET_DDL('TABLE', table_name) 
FROM user_tables;

SELECT DBMS_METADATA.GET_DDL('INDEX', index_name) 
FROM user_indexes;

SELECT DBMS_METADATA.GET_DDL('VIEW', view_name) 
FROM user_views;

SELECT DBMS_METADATA.GET_DDL('SEQUENCE', sequence_name) 
FROM user_sequences;