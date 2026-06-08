-- Lesson 08 Exercise: Assignment History

-- Clean up old objects if the script is re-run.
BEGIN EXECUTE IMMEDIATE 'DROP TRIGGER trg_ticket_assignment_log'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE fact_ticket_daily'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ticket_assignments'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tickets'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE dim_agent'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Step 1: Source OLTP tables.
CREATE TABLE tickets (
    ticket_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title        VARCHAR2(200) NOT NULL,
    status       VARCHAR2(20)  DEFAULT 'open' NOT NULL,
    priority     VARCHAR2(10)  DEFAULT 'medium' NOT NULL,
    created_at   TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    resolved_at  TIMESTAMP,
    assigned_to  NUMBER,
    CONSTRAINT chk_ticket_status CHECK (status IN ('open', 'in_progress', 'resolved', 'cancelled')),
    CONSTRAINT chk_ticket_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

CREATE TABLE ticket_assignments (
    assignment_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id     NUMBER    NOT NULL REFERENCES tickets(ticket_id),
    assigned_to   NUMBER    NOT NULL,
    assigned_by   NUMBER,
    valid_from    TIMESTAMP NOT NULL,
    valid_to      TIMESTAMP
);

CREATE INDEX idx_ticket_assignments_lookup
ON ticket_assignments (ticket_id, valid_from, valid_to);

-- Step 3: Trigger that logs each first assignment and reassignment.
CREATE OR REPLACE TRIGGER trg_ticket_assignment_log
    AFTER INSERT OR UPDATE OF assigned_to ON tickets
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        IF :NEW.assigned_to IS NOT NULL THEN
            INSERT INTO ticket_assignments (ticket_id, assigned_to, assigned_by, valid_from, valid_to)
            VALUES (:NEW.ticket_id, :NEW.assigned_to, NULL, :NEW.created_at, NULL);
        END IF;
    ELSIF UPDATING THEN
        IF NVL(:OLD.assigned_to, -1) <> NVL(:NEW.assigned_to, -1) THEN
            UPDATE ticket_assignments
               SET valid_to = SYSTIMESTAMP
             WHERE ticket_id = :OLD.ticket_id
               AND valid_to IS NULL;

            IF :NEW.assigned_to IS NOT NULL THEN
                INSERT INTO ticket_assignments (ticket_id, assigned_to, assigned_by, valid_from, valid_to)
                VALUES (:NEW.ticket_id, :NEW.assigned_to, NULL, SYSTIMESTAMP, NULL);
            END IF;
        END IF;
    END IF;
END;
/

-- Step 2: Sample data with at least one reassigned ticket.
INSERT INTO tickets (title, status, priority, resolved_at, assigned_to)
VALUES ('Cannot log in', 'resolved', 'high', SYSTIMESTAMP, 1);

INSERT INTO tickets (title, status, priority, assigned_to)
VALUES ('Payment page error', 'open', 'critical', 2);

INSERT INTO tickets (title, status, priority, resolved_at, assigned_to)
VALUES ('Wrong email notification', 'resolved', 'medium', SYSTIMESTAMP, 3);

INSERT INTO tickets (title, status, priority, assigned_to)
VALUES ('Slow dashboard loading', 'in_progress', 'medium', 4);

INSERT INTO tickets (title, status, priority, assigned_to)
VALUES ('Need password reset', 'open', 'low', 1);

COMMIT;

-- Test reassignment: ticket 2 moves from agent 2 to agent 3.
UPDATE tickets
   SET assigned_to = 3,
       status = 'resolved',
       resolved_at = SYSTIMESTAMP
 WHERE ticket_id = 2;

COMMIT;

-- Check the reassignment history.
SELECT ticket_id,
       assigned_to,
       valid_from,
       valid_to,
       CASE WHEN valid_to IS NULL THEN 'current' ELSE 'old' END AS row_type
FROM ticket_assignments
WHERE ticket_id = 2
ORDER BY valid_from;

-- Step 4: Data warehouse star schema tables.
CREATE TABLE dim_agent (
    agent_key  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_name VARCHAR2(100) NOT NULL,
    team       VARCHAR2(50)  NOT NULL
);

CREATE TABLE fact_ticket_daily (
    date_key         NUMBER       NOT NULL,
    agent_key        NUMBER       NOT NULL REFERENCES dim_agent(agent_key),
    status           VARCHAR2(20) NOT NULL,
    priority         VARCHAR2(10) NOT NULL,
    tickets_created  NUMBER       DEFAULT 0 NOT NULL,
    tickets_resolved NUMBER       DEFAULT 0 NOT NULL,
    CONSTRAINT uq_fact_ticket_daily UNIQUE (date_key, agent_key, status, priority)
);

-- Step 5: Populate dim_agent.
INSERT INTO dim_agent (agent_name, team) VALUES ('Mia Torres', 'Support');
INSERT INTO dim_agent (agent_name, team) VALUES ('Leo Rivera', 'Billing');
INSERT INTO dim_agent (agent_name, team) VALUES ('Ava Chen', 'Support');
INSERT INTO dim_agent (agent_name, team) VALUES ('Noah Brown', 'Platform');
COMMIT;

-- Step 7: Verify after running the Colab ETL.
SELECT f.date_key,
       a.agent_name,
       a.team,
       f.status,
       f.priority,
       f.tickets_created,
       f.tickets_resolved
FROM fact_ticket_daily f
JOIN dim_agent a
  ON a.agent_key = f.agent_key
ORDER BY f.date_key, a.agent_name, f.status, f.priority;
