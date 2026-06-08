import pandas as pd

# EXTRACT
agents_df = pd.read_sql("SELECT agent_key, agent_name, team FROM dim_agent ORDER BY agent_key", engine)
tickets_df = pd.read_sql("SELECT * FROM tickets ORDER BY ticket_id", engine)
assignments_df = pd.read_sql("SELECT * FROM ticket_assignments ORDER BY ticket_id, valid_from", engine)

# 3.  For each ticket, finds who was assigned at `created_at` using:
#`valid_from <= created_at AND (valid_to IS NULL OR valid_to > created_at)`

for column in ["created_at", "resolved_at"]:
    tickets_df[column] = pd.to_datetime(tickets_df[column])

for column in ["valid_from", "valid_to"]:
    assignments_df[column] = pd.to_datetime(assignments_df[column])

# 4. Groups by date, agent, status, priority and counts
created_assign = tickets_df[["ticket_id", "created_at", "status", "priority"]].merge(
    assignments_df,
    on="ticket_id",
    how="inner"
)

created_assign = created_assign[
    (created_assign["created_at"] >= created_assign["valid_from"]) &
    (created_assign["valid_to"].isna() | (created_assign["created_at"] < created_assign["valid_to"]))
].copy()

created_assign["date_key"] = created_assign["created_at"].dt.strftime("%Y%m%d").astype(int)
created_by_day = created_assign.groupby(
    ["date_key", "assigned_to", "status", "priority"]
).size().reset_index(name="tickets_created")
created_by_day = created_by_day.rename(columns={"assigned_to": "agent_key"})

# find who owned each ticket when it was resolved.
resolved_tickets = tickets_df[tickets_df["resolved_at"].notna()].copy()
resolved_assign = resolved_tickets[["ticket_id", "resolved_at", "status", "priority"]].merge(
    assignments_df,
    on="ticket_id",
    how="inner"
)

resolved_assign = resolved_assign[
    (resolved_assign["resolved_at"] >= resolved_assign["valid_from"]) &
    (resolved_assign["valid_to"].isna() | (resolved_assign["resolved_at"] < resolved_assign["valid_to"]))
].copy()

resolved_assign["date_key"] = resolved_assign["resolved_at"].dt.strftime("%Y%m%d").astype(int)
resolved_by_day = resolved_assign.groupby(
    ["date_key", "assigned_to", "status", "priority"]
).size().reset_index(name="tickets_resolved")
resolved_by_day = resolved_by_day.rename(columns={"assigned_to": "agent_key"})

# Put created and resolved counts in one fact table.
fact = created_by_day.merge(
    resolved_by_day,
    on=["date_key", "agent_key", "status", "priority"],
    how="outer"
)

fact["tickets_created"] = fact["tickets_created"].fillna(0).astype(int)
fact["tickets_resolved"] = fact["tickets_resolved"].fillna(0).astype(int)

print("Fact rows ready to load:")
display(fact)

# 5. Inserts into `fact_ticket_daily`
fact_insert_sql = """
MERGE INTO fact_ticket_daily f
USING (
    SELECT :1 AS date_key,
           :2 AS agent_key,
           :3 AS status,
           :4 AS priority,
           :5 AS tickets_created,
           :6 AS tickets_resolved
    FROM dual
) src
ON (f.date_key = src.date_key
    AND f.agent_key = src.agent_key
    AND f.status = src.status
    AND f.priority = src.priority)
WHEN NOT MATCHED THEN INSERT
    (date_key, agent_key, status, priority, tickets_created, tickets_resolved)
    VALUES
    (src.date_key, src.agent_key, src.status, src.priority, src.tickets_created, src.tickets_resolved)
WHEN MATCHED THEN UPDATE SET
    tickets_created = src.tickets_created,
    tickets_resolved = src.tickets_resolved
"""

raw_connection = engine.raw_connection()
cursor = raw_connection.cursor()

for _, row in fact.iterrows():
    cursor.execute(fact_insert_sql, [
        int(row["date_key"]),
        int(row["agent_key"]),
        row["status"],
        row["priority"],
        int(row["tickets_created"]),
        int(row["tickets_resolved"])
    ])

raw_connection.commit()
cursor.close()
raw_connection.close()

print(f"Loaded {len(fact)} rows into fact_ticket_daily")
