"""
app/services/application_service.py
──────────────────────────────────────
Track internship applications per user.
"""

from datetime import datetime, timezone
from typing import List

from bson import ObjectId
from fastapi import HTTPException, status
from motor.motor_asyncio import AsyncIOMotorDatabase

from app.schemas.application import (
    ApplicationCreate,
    ApplicationResponse,
    ApplicationListResponse,
    ApplicationStatusUpdate,
    ApplicationNotesUpdate,
)


def _doc_to_response(doc: dict) -> ApplicationResponse:
    return ApplicationResponse(
        id=str(doc["_id"]),
        internship_id=doc["internship_id"],
        internship_title=doc.get("internship_title", ""),
        company=doc.get("company", ""),
        company_logo=doc.get("company_logo", ""),
        status=doc.get("status", 0),
        applied_at=doc["applied_at"],
        updated_at=doc.get("updated_at"),
        notes=doc.get("notes"),
    )


async def create_application(
    db: AsyncIOMotorDatabase,
    user_id: str,
    payload: ApplicationCreate,
) -> ApplicationResponse:
    # Check duplicate
    existing = await db.applications.find_one(
        {"user_id": user_id, "internship_id": payload.internship_id}
    )
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Already applied to this internship.",
        )

    # Fetch internship details for denormalisation
    try:
        oid = ObjectId(payload.internship_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid internship ID.")

    intern_doc = await db.internships.find_one({"_id": oid})
    if not intern_doc:
        raise HTTPException(status_code=404, detail="Internship not found.")

    now = datetime.now(timezone.utc)
    doc = {
        "user_id": user_id,
        "internship_id": payload.internship_id,
        "internship_title": intern_doc.get("title", ""),
        "company": intern_doc.get("company", ""),
        "company_logo": intern_doc.get("company_logo", ""),
        "status": 0,  # ApplicationStatus.applied
        "applied_at": now,
        "updated_at": now,
        "notes": payload.notes,
    }
    result = await db.applications.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc_to_response(doc)


async def list_applications(
    db: AsyncIOMotorDatabase,
    user_id: str,
    requesting_user_id: str,
) -> ApplicationListResponse:
    if user_id != requesting_user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

    cursor = db.applications.find({"user_id": user_id}).sort("applied_at", -1)
    apps: List[ApplicationResponse] = [_doc_to_response(doc) async for doc in cursor]
    return ApplicationListResponse(applications=apps, total=len(apps))


async def update_application_status(
    db: AsyncIOMotorDatabase,
    application_id: str,
    user_id: str,
    payload: ApplicationStatusUpdate,
) -> ApplicationResponse:
    try:
        oid = ObjectId(application_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid application ID.")

    now = datetime.now(timezone.utc)
    doc = await db.applications.find_one_and_update(
        {"_id": oid, "user_id": user_id},
        {"$set": {"status": payload.status, "updated_at": now}},
        return_document=True,
    )
    if not doc:
        raise HTTPException(status_code=404, detail="Application not found.")
    return _doc_to_response(doc)


async def update_application_notes(
    db: AsyncIOMotorDatabase,
    application_id: str,
    user_id: str,
    payload: ApplicationNotesUpdate,
) -> ApplicationResponse:
    try:
        oid = ObjectId(application_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid application ID.")

    now = datetime.now(timezone.utc)
    doc = await db.applications.find_one_and_update(
        {"_id": oid, "user_id": user_id},
        {"$set": {"notes": payload.notes, "updated_at": now}},
        return_document=True,
    )
    if not doc:
        raise HTTPException(status_code=404, detail="Application not found.")
    return _doc_to_response(doc)


async def delete_application(
    db: AsyncIOMotorDatabase,
    application_id: str,
    user_id: str,
) -> dict:
    try:
        oid = ObjectId(application_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid application ID.")

    result = await db.applications.delete_one({"_id": oid, "user_id": user_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Application not found.")
    return {"message": "Application deleted."}
