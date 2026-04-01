"""
app/services/internship_service.py
────────────────────────────────────
CRUD + search logic for internship listings.
"""

import math
from datetime import datetime, timezone
from typing import List, Optional

from bson import ObjectId
from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.schemas.internship import (
    InternshipCreate,
    InternshipResponse,
    InternshipListResponse,
)


def _doc_to_response(
    doc: dict,
    match_score: int = 0,
    bookmarked_ids: set = None,
    applied_ids: set = None,
) -> InternshipResponse:
    bookmarked_ids = bookmarked_ids or set()
    applied_ids = applied_ids or set()
    iid = str(doc["_id"])
    return InternshipResponse(
        id=iid,
        title=doc.get("title", ""),
        company=doc.get("company", ""),
        company_logo=doc.get("company_logo", ""),
        location=doc.get("location", ""),
        type=doc.get("type", ""),
        skills=doc.get("skills", []),
        duration=doc.get("duration", ""),
        stipend=doc.get("stipend", ""),
        domain=doc.get("domain", ""),
        description=doc.get("description"),
        apply_url=doc.get("apply_url"),
        deadline=doc.get("deadline"),
        posted_at=doc.get("posted_at"),
        match_score=match_score,
        is_bookmarked=iid in bookmarked_ids,
        has_applied=iid in applied_ids,
    )


async def _user_meta(db: AsyncIOMotorDatabase, user_id: str):
    """Return (bookmarked_ids_set, applied_ids_set) for a user."""
    bm_cursor = db.bookmarks.find({"user_id": user_id}, {"internship_id": 1})
    bookmarked = {doc["internship_id"] async for doc in bm_cursor}

    ap_cursor = db.applications.find({"user_id": user_id}, {"internship_id": 1})
    applied = {doc["internship_id"] async for doc in ap_cursor}

    return bookmarked, applied


async def search_internships(
    db: AsyncIOMotorDatabase,
    user_id: Optional[str],
    query: Optional[str],
    domain: Optional[str],
    type_: Optional[str],
    location: Optional[str],
    page: int,
    limit: int,
) -> InternshipListResponse:
    filter_: dict = {}

    if query:
        filter_["$text"] = {"$search": query}
    if domain:
        filter_["domain"] = domain
    if type_:
        filter_["type"] = type_
    if location:
        filter_["location"] = {"$regex": location, "$options": "i"}

    total = await db.internships.count_documents(filter_)
    skip = (page - 1) * limit
    cursor = db.internships.find(filter_).skip(skip).limit(limit).sort("posted_at", -1)

    bookmarked, applied = await _user_meta(db, user_id) if user_id else (set(), set())

    results = [
        _doc_to_response(doc, bookmarked_ids=bookmarked, applied_ids=applied)
        async for doc in cursor
    ]

    return InternshipListResponse(
        results=results,
        total=total,
        page=page,
        limit=limit,
        pages=math.ceil(total / limit) if total else 0,
    )


async def get_internship(
    db: AsyncIOMotorDatabase,
    internship_id: str,
    user_id: Optional[str] = None,
) -> InternshipResponse:
    try:
        oid = ObjectId(internship_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid internship ID.")
    doc = await db.internships.find_one({"_id": oid})
    if not doc:
        raise HTTPException(status_code=404, detail="Internship not found.")

    bookmarked, applied = await _user_meta(db, user_id) if user_id else (set(), set())
    return _doc_to_response(doc, bookmarked_ids=bookmarked, applied_ids=applied)


async def create_internship(
    db: AsyncIOMotorDatabase,
    payload: InternshipCreate,
) -> InternshipResponse:
    doc = payload.model_dump()
    doc["posted_at"] = datetime.now(timezone.utc)
    result = await db.internships.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc_to_response(doc)
