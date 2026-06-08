

-- Exercise 1 & 2

CREATE TABLE comments (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id     NUMBER NOT NULL,
    user_id     NUMBER NOT NULL,
    content     VARCHAR2(1000) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comments_task
        FOREIGN KEY (task_id) REFERENCES tasks(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id) REFERENCES users(id),

    CONSTRAINT ck_comments_content_not_empty
        CHECK (TRIM(content) IS NOT NULL)
);



-- ============================================================
-- Exercise 3 — CRUD Challenge 
--  Using ORM only.
-- ============================================================
-- Exercise 4 — Migration Rollback
-- Scenario: a bad column called estimated_hours was added and applied.
ALTER TABLE tasks ADD COLUMN estimated_hours;

-- In Colab the rollback command is:
-- command.downgrade(alembic_cfg, "-1")
--
ALTER TABLE tasks DROP COLUMN estimated_hours;



COMMIT;

