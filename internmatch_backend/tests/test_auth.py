"""
tests/test_auth.py
───────────────────
Integration tests for /auth endpoints using an in-memory MongoDB.
"""

import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from motor.motor_asyncio import AsyncIOMotorClient

from app.main import app
from app.core.config import settings

# Override DB with an isolated test database
TEST_DB = "internmatch_test"


@pytest_asyncio.fixture(autouse=True)
async def clean_test_db():
    """Drop and recreate the test collections before each test."""
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    await client[TEST_DB].users.drop()
    yield
    await client[TEST_DB].users.drop()
    client.close()


@pytest_asyncio.fixture
async def http_client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac


# ── Register ──────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_register_success(http_client):
    resp = await http_client.post(
        "/api/v1/auth/register",
        json={"name": "Alice", "email": "alice@test.com", "password": "secret123"},
    )
    assert resp.status_code == 201
    data = resp.json()
    assert "access_token" in data
    assert data["email"] == "alice@test.com"


@pytest.mark.asyncio
async def test_register_duplicate_email(http_client):
    payload = {"name": "Bob", "email": "bob@test.com", "password": "secret123"}
    await http_client.post("/api/v1/auth/register", json=payload)
    resp = await http_client.post("/api/v1/auth/register", json=payload)
    assert resp.status_code == 409


@pytest.mark.asyncio
async def test_register_short_password(http_client):
    resp = await http_client.post(
        "/api/v1/auth/register",
        json={"name": "Carol", "email": "carol@test.com", "password": "abc"},
    )
    assert resp.status_code == 422


# ── Login ─────────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_login_success(http_client):
    await http_client.post(
        "/api/v1/auth/register",
        json={"name": "Dave", "email": "dave@test.com", "password": "secret123"},
    )
    resp = await http_client.post(
        "/api/v1/auth/login",
        json={"email": "dave@test.com", "password": "secret123"},
    )
    assert resp.status_code == 200
    assert "access_token" in resp.json()


@pytest.mark.asyncio
async def test_login_wrong_password(http_client):
    await http_client.post(
        "/api/v1/auth/register",
        json={"name": "Eve", "email": "eve@test.com", "password": "correct"},
    )
    resp = await http_client.post(
        "/api/v1/auth/login",
        json={"email": "eve@test.com", "password": "wrong"},
    )
    assert resp.status_code == 401
