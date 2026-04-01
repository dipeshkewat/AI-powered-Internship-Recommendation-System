"""
app/services/bookmark_service.py
──────────────────────────────────
Add / remove / list bookmarked internships for a user.
"""

from typing import List

from bson import ObjectId
from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.schemas.internship import InternshipResponse
from app.services.internship_service import _doc_to_response, _user_meta


async def add_bookmark(
    db: AsyncIOMotorDatabase,
    user_id: str,
    internship_id: str,
    requesting_user_id: str,
) -> dict:
    if user_id != requesting_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

    # Verify internship exists
    try:
        oid = ObjectId(internship_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid internship ID.")
    if not await db.internships.find_one({"_id": oid}):
        raise HTTPException(status_code=404, detail="Internship not found.")

    await db.bookmarks.update_one(
        {"user_id": user_id, "internship_id": internship_id},
        {"$setOnInsert": {"user_id": user_id, "internship_id": internship_id}},
        upsert=True,
    )
    return {"message": "Bookmarked successfully."}


async def remove_bookmark(
    db: AsyncIOMotorDatabase,
    user_id: str,
    internship_id: str,
    requesting_user_id: str,
) -> dict:
    if user_id != requesting_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

    result = await db.bookmarks.delete_one(
        {"user_id": user_id, "internship_id": internship_id}
    )
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Bookmark not found.")
    return {"message": "Bookmark removed."}


async def get_bookmarks(
    db: AsyncIOMotorDatabase,
    user_id: str,
    requesting_user_id: str,
) -> dict:
    if user_id != requesting_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

    bm_docs = db.bookmarks.find({"user_id": user_id})
    internship_ids = [doc["internship_id"] async for doc in bm_docs]

    if not internship_ids:
        return {"bookmarks": []}

    oids = []
    for iid in internship_ids:
        try:
            oids.append(ObjectId(iid))
        except Exception:
            pass

    bookmarked, applied = await _user_meta(db, user_id)
    cursor = db.internships.find({"_id": {"$in": oids}})
    results: List[InternshipResponse] = [
        _doc_to_response(doc, bookmarked_ids=bookmarked, applied_ids=applied)
        async for doc in cursor
    ]
    return {"bookmarks": results}
