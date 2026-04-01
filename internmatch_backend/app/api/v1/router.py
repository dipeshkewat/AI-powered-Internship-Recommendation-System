"""
app/api/v1/router.py
─────────────────────
Aggregates all v1 endpoint routers into a single APIRouter
that main.py mounts under /api/v1.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import auth, users, internships, recommendations, applications

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(internships.router)
api_router.include_router(recommendations.router)
api_router.include_router(applications.router)
