
## Step 1 

For this step, I generate the source tables for the daily system. The tickets table stores the current information of each ticket, like the title, status, t priority, creation date, resolution date, and current assigned agent. 

## Step 2 

The activuty ask us to insert test tickets into the database. Some tickets were already resolved, and some were still open or in progress.

## Step 3

In this step, I created a trigger that runs automatically when a ticket is inserted or when its assigned_to value changes. When a new ticket is created, the trigger saves the first assignment in ticket_assignments. When the ticket is reassigned, the trigger closes the old assignment by setting valid_to, then opens a new assignment with a new valid_from. 

## Step 4

Here it was created the data warehouse tables. The agent table stores agent details, like name and team. The fact_ticket_daily table stores daily numbers, like how many tickets were created and resolved by each agent, status, and priority. I understood that the warehouse it is made to answer reporting questions faster and more clearly.

## Step 5
Here it was inserted the agents into dim_agent. These agents are used later when the fact table needs to connect a daily number with an agent name and team.

## Step 6 

In this step, i used Colab to move data from the OLTP tables into the data warehouse. ETL means Extract, Transform, and Load. First, the code extracts tickets and ticket_assignments from the database. Then it transforms the data by checking the assignment timeline. Finally, it loads the daily counts into fact_ticket_daily.


## Step 7

To verify as whole that the project worked, we ran a query that joins fact_ticket_daily with dim_agent. This makes the report show the date, agent name, team, status, priority, etc The created count should belong to the original agent, and the resolved count should belong to the agent who had the ticket when it was resolved.
