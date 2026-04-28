"""
app/api/v1/endpoints/internships.py
─────────────────────────────────────
GET  /internships           – search & filter with pagination
GET  /internships/{id}      – single internship detail
POST /internships           – create listing (admin / seeding)
POST /internships/{id}/apply – apply to an internship
"""

from typing import Optional

from fastapi import APIRouter, Query

from app.core.deps import DB, CurrentUserId, OptionalCurrentUserId
from app.schemas.internship import (
    InternshipCreate,
    InternshipResponse,
    InternshipListResponse,
)
from app.schemas.application import ApplicationCreate, ApplicationResponse
from app.services import internship_service, application_service

router = APIRouter(prefix="/internships", tags=["internships"])


@router.get("", response_model=InternshipListResponse)
async def search_internships(
    db: DB,
    current_user: OptionalCurrentUserId,
    q: Optional[str] = Query(None, description="Full-text keyword search"),
    domain: Optional[str] = Query(None, description="Filter by domain (e.g. AI/ML)"),
    type: Optional[str] = Query(None, description="Remote / Hybrid / On-site"),
    location: Optional[str] = Query(None, description="Partial match on location string"),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    return await internship_service.search_internships(
        db=db,
        user_id=current_user,
        query=q,
        domain=domain,
        type_=type,
        location=location,
        page=page,
        limit=limit,
    )


@router.get("/{internship_id}", response_model=InternshipResponse)
async def get_internship(
    internship_id: str,
    db: DB,
    current_user: OptionalCurrentUserId,
):
    return await internship_service.get_internship(db, internship_id, current_user)


@router.post("", response_model=InternshipResponse, status_code=201)
async def create_internship(
    payload: InternshipCreate,
    db: DB,
    _: CurrentUserId,
):
    """Admin / seeding endpoint to add internship listings."""
    return await internship_service.create_internship(db, payload)


@router.post("/{internship_id}/apply", response_model=ApplicationResponse, status_code=201)
async def apply_to_internship(
    internship_id: str,
    db: DB,
    current_user: CurrentUserId,
    notes: Optional[str] = None,
):
    payload = ApplicationCreate(internship_id=internship_id, notes=notes)
    return await application_service.create_application(db, current_user, payload)
