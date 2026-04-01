# InternMatch — FastAPI Backend

AI-powered internship recommendation API built with **FastAPI · MongoDB · Random Forest (scikit-learn) · JWT Auth**.

---

## Architecture

```
internmatch_backend/
├── app/
│   ├── main.py                     # FastAPI app factory + lifespan hooks
│   ├── api/
│   │   └── v1/
│   │       ├── router.py           # Aggregates all endpoint routers
│   │       └── endpoints/
│   │           ├── auth.py         # POST /auth/register|login|refresh
│   │           ├── users.py        # GET|PUT /users/{id}/profile, bookmarks
│   │           ├── internships.py  # GET|POST /internships, apply
│   │           ├── recommendations.py  # POST /recommendations (ML)
│   │           └── applications.py # PATCH|DELETE /applications/{id}
│   ├── core/
│   │   ├── config.py               # Pydantic Settings (env vars)
│   │   ├── security.py             # JWT + bcrypt helpers
│   │   └── deps.py                 # FastAPI dependency injectors
│   ├── db/
│   │   ├── database.py             # Motor async MongoDB client
│   │   └── indexes.py              # MongoDB index creation
│   ├── ml/
│   │   ├── recommender.py          # Random Forest wrapper
│   │   └── artifacts/              # joblib model files (gitignored)
│   ├── schemas/                    # Pydantic request/response models
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── internship.py
│   │   └── application.py
│   └── services/                   # Business logic layer
│       ├── auth_service.py
│       ├── user_service.py
│       ├── internship_service.py
│       ├── recommendation_service.py
│       ├── bookmark_service.py
│       └── application_service.py
├── scripts/
│   ├── train_model.py              # Train & save Random Forest artifacts
│   └── seed_db.py                  # Seed MongoDB with 35+ internship listings
├── tests/
│   └── test_auth.py
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── .env.example
```

---

## Quick Start

### 1. Prerequisites

- Python 3.11+
- MongoDB 7 (local or Atlas)
- (Optional) Docker & Docker Compose

### 2. Local setup

```bash
# Clone and enter the directory
cd internmatch_backend

# Create virtual environment
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env → set MONGODB_URL, JWT_SECRET_KEY
```

### 3. Train the ML model

```bash
python scripts/train_model.py
```

This generates:
- `app/ml/artifacts/rf_model.joblib`
- `app/ml/artifacts/encoders.joblib`

> If you skip this step, the server falls back to a heuristic scoring engine automatically.

### 4. Seed the database

```bash
python scripts/seed_db.py
```

Inserts 35+ real-world Indian tech internship listings across all domains.

### 5. Run the server

```bash
uvicorn app.main:app --reload
```

API is live at: **http://localhost:8000**  
Interactive docs: **http://localhost:8000/docs**

---

## Docker Compose

```bash
# Start API + MongoDB
docker compose up --build

# Start with Mongo Express UI (http://localhost:8081)
docker compose --profile dev up --build

# Seed inside container
docker compose exec api python scripts/seed_db.py

# Train model inside container
docker compose exec api python scripts/train_model.py
```

---

## API Reference

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Create account, returns JWT pair |
| POST | `/api/v1/auth/login` | Authenticate, returns JWT pair |
| POST | `/api/v1/auth/refresh` | Exchange refresh token for new pair |

**Register request:**
```json
{ "name": "Alice", "email": "alice@example.com", "password": "secret123" }
```

**Login request:**
```json
{ "email": "alice@example.com", "password": "secret123" }
```

**Token response:**
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<jwt>",
  "token_type": "bearer",
  "user_id": "664abc...",
  "name": "Alice",
  "email": "alice@example.com"
}
```

All protected endpoints require the header:
```
Authorization: Bearer <access_token>
```

---

### Profile

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/users/{user_id}/profile` | ✅ | Fetch profile |
| PUT | `/api/v1/users/{user_id}/profile` | ✅ | Update profile |

**Profile update body (all fields optional):**
```json
{
  "name": "Alice",
  "skills": ["Flutter", "Python", "ML"],
  "cgpa": 8.5,
  "interests": ["AI/ML", "App Dev"],
  "preferred_location": "Bangalore, India",
  "preferred_type": "Hybrid",
  "college": "IIT Bombay",
  "graduation_year": 2025
}
```

---

### Recommendations (ML Engine)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/recommendations` | ✅ | Get ML-ranked internships |

**Request:**
```json
{
  "skills": ["Flutter", "Dart", "Firebase"],
  "cgpa": 8.5,
  "interests": ["App Dev", "UI/UX"],
  "preferred_location": "Bangalore, India",
  "preferred_type": "Hybrid",
  "top_n": 10
}
```

**Response:**
```json
{
  "recommendations": [
    {
      "id": "664...",
      "title": "Flutter Developer Intern",
      "company": "Google",
      "match_score": 92,
      "domain": "App Dev",
      "skills": ["Flutter", "Dart", "Firebase"],
      "stipend": "₹50,000/mo",
      "type": "Hybrid",
      ...
    }
  ]
}
```

---

### Internships

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/internships` | ✅ | Search & filter with pagination |
| GET | `/api/v1/internships/{id}` | ✅ | Get single internship |
| POST | `/api/v1/internships` | ✅ | Create listing (admin/seed) |
| POST | `/api/v1/internships/{id}/apply` | ✅ | Apply to internship |

**Search query parameters:**
- `q` — full-text keyword search
- `domain` — e.g. `AI/ML`, `App Dev`, `Web`
- `type` — `Remote` / `Hybrid` / `On-site`
- `location` — partial string match
- `page`, `limit` — pagination (default: page=1, limit=20)

---

### Bookmarks

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/users/{user_id}/bookmarks/{internship_id}` | ✅ | Add bookmark |
| DELETE | `/api/v1/users/{user_id}/bookmarks/{internship_id}` | ✅ | Remove bookmark |
| GET | `/api/v1/users/{user_id}/bookmarks` | ✅ | List bookmarked internships |

---

### Applications

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/users/{user_id}/applications` | ✅ | List user's applications |
| PATCH | `/api/v1/applications/{id}/status` | ✅ | Update status (0–4) |
| PATCH | `/api/v1/applications/{id}/notes` | ✅ | Update notes |
| DELETE | `/api/v1/applications/{id}` | ✅ | Delete application |

**Status codes:**
| Value | Label |
|-------|-------|
| 0 | Applied |
| 1 | In Review |
| 2 | Shortlisted |
| 3 | Rejected |
| 4 | Offered 🎉 |

---

## ML Model Details

| Property | Value |
|----------|-------|
| Algorithm | Random Forest Classifier (scikit-learn) |
| Feature dimensions | 45 (multi-hot skills + CGPA + one-hot interests/location/type) |
| Training samples | 3,000 synthetic profiles (300 × 10 domains) |
| Output | Domain probability map → match score (0–100) |
| Fallback | Heuristic keyword scoring (no model required for dev) |

**Feature vector breakdown:**
```
[0:25]   skills    → multi-hot (25 known skills)
[25]     cgpa      → normalised float (÷10)
[26:36]  interests → multi-hot (10 domains)
[36:41]  location  → one-hot (5 locations)
[41:45]  type      → one-hot (4 work types)
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_URL` | `mongodb://localhost:27017` | MongoDB connection string |
| `MONGODB_DB_NAME` | `internmatch` | Database name |
| `JWT_SECRET_KEY` | `dev-secret-...` | **Change in production** |
| `JWT_ALGORITHM` | `HS256` | JWT signing algorithm |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | `60` | Access token TTL |
| `REFRESH_TOKEN_EXPIRE_DAYS` | `7` | Refresh token TTL |
| `MODEL_PATH` | `app/ml/artifacts/rf_model.joblib` | Path to trained model |
| `CORS_ORIGINS` | `["http://localhost:3000"]` | Allowed CORS origins |

---

## Running Tests

```bash
pytest tests/ -v
```

---

## Deployment (Render / Railway)

1. Push to GitHub.
2. Connect repo to Render/Railway.
3. Set build command: `pip install -r requirements.txt`
4. Set start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Add all environment variables from `.env.example`.
6. Set `MONGODB_URL` to your MongoDB Atlas connection string.

---

*InternMatch PRD v1.0 · Built by Dipesh · 2025*
