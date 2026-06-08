

-- EXERCISE 1: Define "Team Velocity"

WITH date_window AS (
    SELECT GREATEST(TRUNC(MAX(created_at)) - TRUNC(MIN(created_at)) + 1, 1) AS days_in_window
    FROM   tasks
),
team_counts AS (
    SELECT t.id,
           t.name AS team_name,
           COUNT(DISTINCT u.id) AS team_members,
           COUNT(CASE
                     WHEN ts.status = 'completed'
                      AND ts.completed_at IS NOT NULL THEN ts.id
                 END) AS completed_tasks
    FROM   teams t
    LEFT   JOIN users u ON u.team_id = t.id
    LEFT   JOIN tasks ts ON ts.assigned_to = u.id
    GROUP  BY t.id, t.name
),
velocities AS (
    SELECT tc.team_name,
           tc.team_members,
           tc.completed_tasks,
           ROUND(tc.completed_tasks / NULLIF(tc.team_members * dw.days_in_window, 0), 3)
               AS velocity_tasks_per_member_per_day
    FROM   team_counts tc
    CROSS  JOIN date_window dw
),
overall_average AS (
    SELECT AVG(velocity_tasks_per_member_per_day) AS avg_velocity
    FROM   velocities
)
SELECT v.team_name,
       v.team_members,
       v.completed_tasks,
       v.velocity_tasks_per_member_per_day,
       CASE
           WHEN v.velocity_tasks_per_member_per_day < oa.avg_velocity THEN 'Below average'
           ELSE 'At or above average'
       END AS velocity_flag
FROM   velocities v
CROSS  JOIN overall_average oa
ORDER  BY v.velocity_tasks_per_member_per_day DESC NULLS LAST;


-- EXERCISE 2: Define "On-Time Delivery Rate"
WITH completed_due_tasks AS (
    SELECT priority,
           due_date,
           completed_at,
           CASE
               WHEN completed_at < CAST(due_date + 1 AS TIMESTAMP) THEN 1
               ELSE 0
           END AS on_time_flag,
           CASE
               WHEN completed_at >= CAST(due_date + 1 AS TIMESTAMP) THEN
                    EXTRACT(DAY    FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP))) * 24
                  + EXTRACT(HOUR   FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP)))
                  + EXTRACT(MINUTE FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP))) / 60
                  + EXTRACT(SECOND FROM (completed_at - CAST(due_date + 1 AS TIMESTAMP))) / 3600
           END AS late_hours
    FROM   tasks
    WHERE  status = 'completed'
      AND  completed_at IS NOT NULL
      AND  due_date IS NOT NULL
)
SELECT priority,
       COUNT(*) AS completed_due_tasks,
       ROUND(SUM(on_time_flag) * 100.0 / NULLIF(COUNT(*), 0), 1) AS on_time_delivery_rate_pct,
       ROUND(AVG(late_hours), 1) AS avg_lateness_hours_for_late_tasks
FROM   completed_due_tasks
GROUP  BY priority
ORDER  BY CASE priority
              WHEN 'critical' THEN 1
              WHEN 'high'     THEN 2
              WHEN 'medium'   THEN 3
              WHEN 'low'      THEN 4
          END;


-- EXERCISE 3: Improve "Tasks per Team" (KPI 2 from class)

WITH team_stats AS (
    SELECT t.id,
           t.name AS team_name,
           COUNT(ts.id) AS total_tasks,
           COUNT(CASE
                     WHEN ts.status IN ('open', 'in_progress', 'blocked') THEN 1
                 END) AS active_tasks,
           COUNT(CASE
                     WHEN ts.status = 'completed' THEN 1
                 END) AS completed_tasks,
           COUNT(CASE
                     WHEN ts.status != 'cancelled' THEN 1
                 END) AS non_cancelled_tasks
    FROM   teams t
    LEFT   JOIN users u ON u.team_id = t.id
    LEFT   JOIN tasks ts ON ts.assigned_to = u.id
    GROUP  BY t.id, t.name
)
SELECT team_name,
       total_tasks,
       active_tasks,
       ROUND(completed_tasks * 100.0 / NULLIF(non_cancelled_tasks, 0), 1) AS completion_rate_pct,
       CASE
           WHEN active_tasks > 10 THEN 'Overloaded'
           WHEN active_tasks BETWEEN 5 AND 10 THEN 'Healthy'
           ELSE 'Underutilized'
       END AS health_score
FROM   team_stats
ORDER  BY active_tasks DESC;


-- EXERCISE 4: Improve "Average Resolution Time" (KPI 5 from class)

WITH completed_tasks AS (
    SELECT priority,
           EXTRACT(DAY    FROM (completed_at - created_at)) * 24
         + EXTRACT(HOUR   FROM (completed_at - created_at))
         + EXTRACT(MINUTE FROM (completed_at - created_at)) / 60
         + EXTRACT(SECOND FROM (completed_at - created_at)) / 3600
             AS resolution_hours
    FROM   tasks
    WHERE  status = 'completed'
      AND  completed_at IS NOT NULL
),
priority_stats AS (
    SELECT priority,
           COUNT(*) AS completed_task_count,
           ROUND(AVG(resolution_hours), 1) AS avg_resolution_hours,
           ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_hours), 1)
               AS median_resolution_hours,
           ROUND(MIN(resolution_hours), 1) AS fastest_resolution_hours,
           ROUND(MAX(resolution_hours), 1) AS slowest_resolution_hours,
           CASE priority
               WHEN 'critical' THEN 24
               WHEN 'high'     THEN 72
               WHEN 'medium'   THEN 168
               WHEN 'low'      THEN 336
           END AS target_sla_hours
    FROM   completed_tasks
    GROUP  BY priority
)
SELECT priority,
       completed_task_count,
       avg_resolution_hours,
       median_resolution_hours,
       fastest_resolution_hours,
       slowest_resolution_hours,
       target_sla_hours,
       CASE
           WHEN avg_resolution_hours <= target_sla_hours THEN 'Target met'
           ELSE 'Target missed'
       END AS target_status,
       CASE
           WHEN completed_task_count < 3 THEN 'Small sample'
           ELSE 'OK'
       END AS sample_note
FROM   priority_stats
ORDER  BY CASE priority
              WHEN 'critical' THEN 1
              WHEN 'high'     THEN 2
              WHEN 'medium'   THEN 3
              WHEN 'low'      THEN 4
          END;



-- EXERCISE 5: Improve "Overdue Tasks" (KPI 7 from class)

WITH overdue_tasks AS (
    SELECT ts.title,
           COALESCE(u.full_name, 'Unassigned') AS assignee,
           COALESCE(t.name, 'No team') AS team_name,
           ts.priority,
           ts.due_date,
           TRUNC(SYSDATE) - ts.due_date AS days_overdue,
           CASE
               WHEN ts.priority = 'critical'
                AND TRUNC(SYSDATE) - ts.due_date > 0 THEN 'CRITICAL'
               WHEN ts.priority = 'high'
                AND TRUNC(SYSDATE) - ts.due_date > 2 THEN 'HIGH'
               WHEN ts.priority = 'medium'
                AND TRUNC(SYSDATE) - ts.due_date > 5 THEN 'MEDIUM'
               ELSE 'LOW'
           END AS severity,
           CASE
               WHEN ts.priority = 'critical'
                AND TRUNC(SYSDATE) - ts.due_date > 0 THEN 1
               WHEN ts.priority = 'high'
                AND TRUNC(SYSDATE) - ts.due_date > 2 THEN 2
               WHEN ts.priority = 'medium'
                AND TRUNC(SYSDATE) - ts.due_date > 5 THEN 3
               ELSE 4
           END AS severity_rank
    FROM   tasks ts
    LEFT   JOIN users u ON u.id = ts.assigned_to
    LEFT   JOIN teams t ON t.id = u.team_id
    WHERE  ts.due_date < TRUNC(SYSDATE)
      AND  ts.status NOT IN ('completed', 'cancelled')
      AND  ts.due_date IS NOT NULL
),
report_rows AS (
    SELECT 1 AS row_sort,
           severity_rank,
           days_overdue AS days_sort,
           'DETAIL' AS row_type,
           title,
           assignee,
           team_name,
           priority,
           due_date,
           days_overdue,
           severity,
           CAST(NULL AS NUMBER) AS overdue_count,
           CAST(NULL AS NUMBER) AS avg_days_overdue
    FROM   overdue_tasks
    UNION ALL
    SELECT 2 AS row_sort,
           severity_rank,
           NULL AS days_sort,
           'SUMMARY' AS row_type,
           'Total for ' || severity AS title,
           NULL AS assignee,
           NULL AS team_name,
           NULL AS priority,
           NULL AS due_date,
           NULL AS days_overdue,
           severity,
           COUNT(*) AS overdue_count,
           ROUND(AVG(days_overdue), 1) AS avg_days_overdue
    FROM   overdue_tasks
    GROUP  BY severity, severity_rank
)
SELECT row_type,
       title,
       assignee,
       team_name,
       priority,
       due_date,
       days_overdue,
       severity,
       overdue_count,
       avg_days_overdue
FROM   report_rows
ORDER  BY row_sort, severity_rank, days_sort DESC NULLS LAST;


-- EXERCISE 6: Fix the "Productivity Score"

WITH scored_tasks AS (
    SELECT assigned_to,
           completed_at,
           CASE priority
               WHEN 'critical' THEN 4
               WHEN 'high'     THEN 3
               WHEN 'medium'   THEN 2
               WHEN 'low'      THEN 1
           END AS priority_points
    FROM   tasks
    WHERE  status = 'completed'
      AND  completed_at IS NOT NULL
),
user_scores AS (
    SELECT u.full_name AS owner_name,
           COUNT(st.priority_points) AS completed_tasks,
           COALESCE(SUM(st.priority_points), 0) AS weighted_completed_points,
           CASE
               WHEN COUNT(st.priority_points) = 0 THEN 1
               ELSE GREATEST(
                        TRUNC(CAST(MAX(st.completed_at) AS DATE))
                      - TRUNC(CAST(MIN(st.completed_at) AS DATE)) + 1,
                        1
                    )
           END AS active_days
    FROM   users u
    LEFT   JOIN scored_tasks st ON st.assigned_to = u.id
    GROUP  BY u.id, u.full_name
    UNION ALL
    SELECT 'Unassigned' AS owner_name,
           COUNT(*) AS completed_tasks,
           COALESCE(SUM(priority_points), 0) AS weighted_completed_points,
           CASE
               WHEN COUNT(*) = 0 THEN 1
               ELSE GREATEST(
                        TRUNC(CAST(MAX(completed_at) AS DATE))
                      - TRUNC(CAST(MIN(completed_at) AS DATE)) + 1,
                        1
                    )
           END AS active_days
    FROM   scored_tasks
    WHERE  assigned_to IS NULL
    HAVING COUNT(*) > 0
)
SELECT owner_name,
       completed_tasks,
       weighted_completed_points,
       active_days,
       ROUND(weighted_completed_points / NULLIF(active_days, 0), 2)
           AS weighted_completed_points_per_day
FROM   user_scores
ORDER  BY weighted_completed_points_per_day DESC;


-- EXERCISE 7: Fix the "Team Efficiency"


SELECT t.name AS team_name,
       COUNT(CASE
                 WHEN ts.status != 'cancelled' THEN 1
             END) AS total_valid_tasks,
       COUNT(CASE
                 WHEN ts.status = 'completed' THEN 1
             END) AS completed_tasks,
       ROUND(
           COUNT(CASE WHEN ts.status = 'completed' THEN 1 END) * 100.0
           / NULLIF(COUNT(CASE WHEN ts.status != 'cancelled' THEN 1 END), 0),
           1
       ) AS team_efficiency_pct
FROM   teams t
LEFT   JOIN users u ON u.team_id = t.id
LEFT   JOIN tasks ts ON ts.assigned_to = u.id
GROUP  BY t.id, t.name
ORDER  BY team_efficiency_pct DESC NULLS LAST;


-- EXERCISE 8: Fix the "Urgency Index"
WITH task_scores AS (
    SELECT title,
           status,
           priority,
           due_date,
           CASE priority
               WHEN 'critical' THEN 4
               WHEN 'high'     THEN 3
               WHEN 'medium'   THEN 2
               WHEN 'low'      THEN 1
           END AS priority_weight,
           CASE
               WHEN due_date IS NULL THEN NULL
               ELSE due_date - TRUNC(SYSDATE)
           END AS days_until_due
    FROM   tasks
    WHERE  status NOT IN ('completed', 'cancelled')
)
SELECT title,
       status,
       priority,
       due_date,
       days_until_due,
       priority_weight * 10 - NVL(days_until_due, 999) AS urgency_score
FROM   task_scores
ORDER  BY urgency_score DESC;
