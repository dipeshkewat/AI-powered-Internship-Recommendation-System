"""
app/db/indexes.py
─────────────────
Creates MongoDB indexes on startup.
Safe to call repeatedly (Motor is idempotent with create_index).
"""

from motor.motor_asyncio import AsyncIOMotorDatabase


async def create_indexes(db: AsyncIOMotorDatabase) -> None:
    # users
    await db.users.create_index("email", unique=True)

    # internships
    await db.internships.create_index([("title", "text"), ("company", "text"), ("description", "text")])
    await db.internships.create_index("domain")
    await db.internships.create_index("type")
    await db.internships.create_index("location")
    await db.internships.create_index("skills")

    # applications
    await db.applications.create_index([("user_id", 1), ("internship_id", 1)], unique=True)
    await db.applications.create_index("user_id")

    # bookmarks
    await db.bookmarks.create_index([("user_id", 1), ("internship_id", 1)], unique=True)
    await db.bookmarks.create_index("user_id")
