## Exercise 1: Team Velocity

I defined team velocity as completed tasks per team member per day. This is fairer than only counting completed tasks because a small team and a large team do not have the same number of people. Since there are no story points in the database, one completed task counts as one unit of work.

## Exercise 2: On-Time Delivery Rate

In this exercise I defined on-time as completed before the end of the due date. Tasks with no due date are ignored because they cannot be judged as on time or late.

## Exercise 3: Improved Tasks per Team

The initial KPI counted all tasks, even completed and cancelled ones. That can make a team look busy when it may not have active work. The new query shows total tasks, active tasks, completion rate, and a health score.

## Exercise 4: Improved Average Resolution Time

The query mixed all priorities into one average. That hides important differences. A critical task should not be judged with the same target as a low-priority task. The new query groups by priority and adds average, median, fastest time, slowest time, SLA target, and a small sample warning.

## Exercise 5: Improved Overdue Tasks

The old KPI only counted overdue tasks. That is not enough because it does not show who owns the work or marks the level od prioritization. The new report shows the task, assignee, team, priority, days overdue, severity, and summary rows.

## Exercise 6: Fixed Productivity Score

The bad query counted assigned tasks and called that productivity. That is weak because assigned work is not the same as finished work. The new query counts completed tasks and gives more weight to higher priorities.

## Exercise 7: Fixed Team Efficiency

For this exericse the fixed query applies completed tasks divided by non-cancelled tasks.

## Exercise 8: Fixed Urgency Index

The bad query tried to multiply text and add a date like a number. That does not make sense. The fixed query gives each priority a number and also looks at how close or overdue the due date is.