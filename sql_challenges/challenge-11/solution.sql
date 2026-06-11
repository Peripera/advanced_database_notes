
-- Exercise 1

from sqlalchemy import CheckConstraint

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="CASCADE"),
        nullable=False
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )
    content = Column(String(1000), nullable=False)
    created_at = Column(DateTime, server_default=func.current_timestamp())

    # Bonus: CHECK constraint so content is not empty.
    __table_args__ = (
        CheckConstraint(
            "LENGTH(TRIM(content)) > 0",
            name="ck_comments_content_not_empty"
        ),
    )

    task = relationship("Task", back_populates="comments")
    user = relationship("User", back_populates="comments")

    def __repr__(self):
        return f"<Comment(id={self.id}, task_id={self.task_id}, user_id={self.user_id})>"


Task.comments = relationship(
    "Comment",
    back_populates="task",
    cascade="all, delete-orphan",
    passive_deletes=True
)

User.comments = relationship(
    "Comment",
    back_populates="user"
)


-- Exercise 2 

from alembic import command
import glob

command.revision(
    alembic_cfg,
    autogenerate=True,
    message="add comments table"
)

migration_files = sorted(
    glob.glob('/content/project/alembic/versions/*.py')
)

for f in migration_files:
    print(f)

latest = migration_files[-1]

with open(latest) as f:
    print(f.read())



-- Exercise 3 


with Session(engine) as session:
    devops = Team(
        name="DevOps",
        description="Operations and deployment team"
    )

    diana = User(
        username="diana_ops",
        email="diana@example.com",
        full_name="Diana Ops",
        team=devops
    )

    task_1 = Task(
        title="Configure CI pipeline",
        description="Set up continuous integration for the project",
        status="open",
        priority=1,
        assignee=diana
    )

    task_2 = Task(
        title="Monitor production logs",
        description="Review application logs and alerts",
        status="open",
        priority=2,
        assignee=diana
    )

    task_3 = Task(
        title="Clean old deployment files",
        description="Remove unused deployment artifacts",
        status="open",
        priority=3,
        assignee=diana
    )

    session.add_all([devops, diana, task_1, task_2, task_3])
    session.commit()

    print("Created team:", devops.name)
    print("Created user:", diana.username)

    task_count = session.query(Task).count()
    print("Task count:", task_count)

    task_1.status = "closed"
    session.commit()
    print("Closed task:", task_1.title)

    lowest_priority_task = max(diana.tasks, key=lambda task: task.priority)
    print("Deleting lowest priority task:", lowest_priority_task.title)

    session.delete(lowest_priority_task)
    session.commit()

    remaining_tasks = session.query(Task).filter(Task.assignee == diana).all()

    print("Remaining tasks for diana_ops:")
    for task in remaining_tasks:
        print(f"- {task.title} | status={task.status} | priority={task.priority}")


-- Exercise 4  (Already in collab)

command.downgrade(alembic_cfg, "-1")
