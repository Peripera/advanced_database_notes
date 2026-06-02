# Exercise 5 - Discussion

#### Q1: You're building a patient appointment booking system. A booking requires:
- a) Reserve the time slot
- b) Create the appointment record
- c) Send a confirmation notification
- Which of these should be inside the transaction? Which should be outside? Why?

A booking requires reserving the time slot, creating the appointment record, and sending a confirmation notification.

The time slot reservation and the appointment record should be inside the transaction. They both change important database data, and they must succeed together.

The confirmation notification should be outside the transaction. Sending a message is not the same as saving database data. If the notification fails, the appointment should not always disappear. The system can retry the notification later.

#### Q2: Your stored procedure calls COMMIT at the end.
- A developer calls your procedure from inside their own larger transaction.
- What problem does this create?

It can create a problem when another developer calls it inside a larger transaction.

The problem is that the procedure saves all pending changes, not only its own changes. This means the larger transaction loses control. The developer cannot rollback the full work anymore because part of it was already committed. One small procedure can accidentally make bigger changes permanent.

## Q3

#### Q3: You have a function called calculate_copay() and a procedure called post_payment().
- A colleague wants to use calculate_copay() inside a SELECT statement.
- Can they? Can they do the same with post_payment()? Why or why not?

They cannot use post_payment() the same way if it is a procedure. A procedure does an action, like updating data or committing a payment. It does not return a normal value for a SELECT statement. Procedures are called with EXEC or CALL, not inside SELECT.