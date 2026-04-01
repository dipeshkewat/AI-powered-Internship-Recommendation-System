"""
app/services/user_service.py
──────────────────────────────
Business logic for user profile management.
"""

from bson import ObjectId
from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.schemas.user import ProfileUpdate, ProfileResponse


def _doc_to_profile(doc: dict) -> ProfileResponse:
    return ProfileResponse(
        id=str(doc["_id"]),
        name=doc.get("name", ""),
        email=doc.get("email", ""),
        skills=doc.get("skills", []),
        cgpa=doc.get("cgpa", 7.0),
        interests=doc.get("interests", []),
        preferred_location=doc.get("preferred_location", ""),
        preferred_type=doc.get("preferred_type", "Any"),
        avatar_url=doc.get("avatar_url"),
        college=doc.get("college"),
        graduation_year=doc.get("graduation_year"),
        resume_url=doc.get("resume_url"),
    )


async def _get_user_or_404(db: AsyncIOMotorDatabase, user_id: str) -> dict:
    try:
        oid = ObjectId(user_id)
    except Exception:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid user ID.")
    doc = await db.users.find_one({"_id": oid})
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")
    return doc


async def get_profile(db: AsyncIOMotorDatabase, user_id: str) -> ProfileResponse:
    doc = await _get_user_or_404(db, user_id)
    return _doc_to_profile(doc)


async def update_profile(
    db: AsyncIOMotorDatabase,
    user_id: str,
    payload: ProfileUpdate,
    requesting_user_id: str,
) -> ProfileResponse:
    if user_id != requesting_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

    try:
        oid = ObjectId(user_id)
    except Exception:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid user ID.")

    updates = payload.model_dump(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No fields to update.")

    result = await db.users.find_one_and_update(
        {"_id": oid},
        {"$set": updates},
        return_document=True,
    )
    if not result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found.")
    return _doc_to_profile(result)
