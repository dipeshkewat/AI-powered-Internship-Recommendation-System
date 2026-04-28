"""
app/main.py
────────────
FastAPI application factory.

Startup lifecycle:
  1. Connect to MongoDB.
  2. Create indexes.
  3. Load ML model artifacts.

Shutdown lifecycle:
  1. Close MongoDB connection.
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1.router import api_router
from app.core.config import settings
from app.db.database import connect_db, close_db, get_client
from app.db.indexes import create_indexes
from app.ml.recommender import recommender

logging.basicConfig(
    level=logging.DEBUG if settings.is_dev else logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ───────────────────────────────────────────────────────────────
    logger.info("Connecting to MongoDB…")
    try:
        await connect_db()
        db = get_client()[settings.MONGODB_DB_NAME]
        await create_indexes(db)
        logger.info("MongoDB ready.")
    except Exception as e:
        logger.error("MongoDB startup error (server will continue): %s", e)

    logger.info("Loading ML model…")
    try:
        recommender.load()
        logger.info("ML model ready.")
    except Exception as e:
        logger.warning("ML model not loaded (will use fallback): %s", e)

    yield

    # ── Shutdown ──────────────────────────────────────────────────────────────
    logger.info("Closing MongoDB connection…")
    await close_db()



def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version="1.0.0",
        description="AI-powered internship recommendation API",
        docs_url="/docs",
        redoc_url="/redoc",
        lifespan=lifespan,
    )

    # ── CORS ──────────────────────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Routes ────────────────────────────────────────────────────────────────
    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    @app.get("/health", tags=["health"])
    async def health_check():
        return JSONResponse({"status": "ok", "version": "1.0.0"})

    return app


app = create_app()
