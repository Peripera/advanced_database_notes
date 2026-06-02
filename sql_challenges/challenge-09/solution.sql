


-- ============================================================
-- Exercise 1: Manual transaction
-- Transfer $50 from Charlie to Alice


SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

UPDATE accounts
SET balance = balance - 50
WHERE account_id = 3;

UPDATE accounts
SET balance = balance + 50
WHERE account_id = 1;

COMMIT;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;


-- ============================================================
-- Exercise 2: Catch yourself with ROLLBACK


/*Start a transfer of $10,000 from Bob (2) to Charlie (3).
- Before committing, check the balances. Does Bob have enough?
- Use ROLLBACK to undo. Verify balances restored.*/


SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

UPDATE accounts
SET balance = balance - 10000
WHERE account_id = 2;

UPDATE accounts
SET balance = balance + 10000
WHERE account_id = 3;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

-- The  changes wasnt commites since Bob didn't have enought money 

ROLLBACK;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;


-- ============================================================
-- Exercise 3: SAVEPOINT checkpoint

 /*You need to:*/
-- 1. Add $25 to Alice's balance
-- 2. Set a savepoint
-- 3. Deduct $25 from Charlie's balance (wrong account — you meant Bob)
-- 4. Rollback to savepoint
-- 5. Deduct $25 from Bob's balance instead
-- 6. Commit

-- Your SQL here:

UPDATE accounts
SET balance = balance + 25
WHERE account_id = 1;

SAVEPOINT after_alice;

UPDATE accounts
SET balance = balance - 25
WHERE account_id = 3;

ROLLBACK TO SAVEPOINT after_alice;

UPDATE accounts
SET balance = balance - 25
WHERE account_id = 2;

COMMIT;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;


-- ============================================================
-- Exercise 4: Stored procedure
/* You need to:
-- 1. Add $25 to Alice's balance
-- 2. Set a savepoint
-- 3. Deduct $25 from Charlie's balance (wrong account — you meant Bob)
-- 4. Rollback to savepoint
-- 5. Deduct $25 from Bob's balance instead
-- 6. Commit

-- Your SQL here:*/

CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Amount must be greater than zero.');
    END IF;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Account not found.');
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

EXEC deposit_funds(3, 75);

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;


-- ============================================================
-- Exercise 5 - Discussion
-- Written answers are in notes.md
/* Q1: You're building a patient appointment booking system.
-- A booking requires:
--   a) Reserve the time slot
--   b) Create the appointment record
--   c) Send a confirmation notification
-- Which of these should be inside the transaction? Which should be outside? Why?

-- Q2: Your stored procedure calls COMMIT at the end.
-- A developer calls your procedure from inside their own larger transaction.
-- What problem does this create?

-- Q3: You have a function called calculate_copay() and a procedure called post_payment().
-- A colleague wants to use calculate_copay() inside a SELECT statement.
-- Can they? Can they do the same with post_payment()? Why or why not?*/

-- ==================================================================

