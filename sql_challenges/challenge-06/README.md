# SQL Challenge 06 – PETCARE Store triggers

## Problem

The House-o-Pets database system needs to be improved and automated by adding triggers to the `PET_CARE_LOG` table.

The goal is to automate the pet care log so that:

1. When a user inserts a new record, the database automatically fills in the update date and the user who inserted the record.
2. A user can only update records that they originally created.
3. Only the manager user, `JOEMANAGER`, can delete records from the log.

Any unauthorized update or delete operation must fail with a custom error message.


The relevant columns used by the triggers are:

```sql
UPDATE_DATE
UPDATED_BY_USER

Squema link: https://www.relationaldbdesign.com/programming-plsql/module1/database-pet-store-schema.php
