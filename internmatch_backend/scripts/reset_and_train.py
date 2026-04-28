"""
scripts/reset_and_train.py

MASTER RESET + REAL DATA IMPORT + MODEL RETRAIN
================================================

This script does THREE things in sequence:

  STEP 1 - NUKE the entire MongoDB database (users, internships, admins,
            profiles, sessions, applications - everything).

  STEP 2 - IMPORT fresh real data from your CSV files:
              - internship_listings_10000.csv  -> internships collection
              - user_training_data.csv          -> users collection

  STEP 3 - RETRAIN the Random Forest model using the real user data
            and save fresh model artifacts so the API uses them.

Run from the project root (internmatch_backend/):
    python scripts/reset_and_train.py

Requirements:
    pip install motor pandas numpy scikit-learn joblib bcrypt python-dotenv
"""

import asyncio
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

# ── Make sure project root is on path ────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

import bcrypt
import joblib
import numpy as np
import pandas as pd
from motor.motor_asyncio import AsyncIOMotorClient
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split

from app.core.config import settings
from app.ml.recommender import (
    ALL_DOMAINS,
    ALL_LOCATIONS,
    ALL_SKILLS,
    ALL_TYPES,
    build_feature_vector,
)

# ── File paths ────────────────────────────────────────────────────────────────
INTERNSHIP_CSV = ROOT / "internship_listings_10000.csv"
USER_CSV = ROOT / "user_training_data.csv"
ARTIFACT_DIR = ROOT / "app" / "ml" / "artifacts"
MODEL_PATH = ARTIFACT_DIR / "rf_model.joblib"
ENCODER_PATH = ARTIFACT_DIR / "encoders.joblib"

DIVIDER = "=" * 70


# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Nuke the database
# ─────────────────────────────────────────────────────────────────────────────

async def nuke_database(db):
    """Drop every collection in the database for a clean slate."""
    print(f"\n{DIVIDER}")
    print("STEP 1  ->  NUKING DATABASE (dropping all collections)")
    print(DIVIDER)

    # List all existing collections
    existing = await db.list_collection_names()

    if not existing:
        print("  Database is already empty - nothing to delete.")
        return

    print(f"  Found {len(existing)} collection(s): {existing}")

    # Drop each one
    for col_name in existing:
        await db.drop_collection(col_name)
        print(f"  [OK]  Dropped '{col_name}'")

    print(f"\n  [DONE]  Database wiped clean. Starting fresh.\n")


# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Import real CSV data
# ─────────────────────────────────────────────────────────────────────────────

def parse_date(date_str):
    if pd.isna(date_str):
        return None
    try:
        return datetime.strptime(str(date_str), "%Y-%m-%d").replace(tzinfo=timezone.utc)
    except Exception:
        return None


async def import_internships(db):
    """Load internship_listings_10000.csv and insert into MongoDB."""
    print(f"  Reading {INTERNSHIP_CSV.name} ...")

    if not INTERNSHIP_CSV.exists():
        print(f"  [ERR]  File not found: {INTERNSHIP_CSV}")
        return 0

    df = pd.read_csv(INTERNSHIP_CSV)
    print(f"  Loaded {len(df):,} rows  |  Columns: {df.columns.tolist()}")

    docs = []
    for _, row in df.iterrows():
        doc = row.where(pd.notna(row), None).to_dict()

        doc["title"]        = doc.get("internship_title") or doc.get("title") or "Unknown Title"
        doc["company"]      = doc.get("company") or "Unknown Company"
        doc["company_logo"] = ""
        doc["location"]     = doc.get("location") or "Remote"
        doc["type"]         = doc.get("mode") or doc.get("type") or "Remote"
        doc["domain"]       = doc.get("domain") or "General"

        skills_raw = doc.get("required_skills") or doc.get("skills") or ""
        sep = "|" if "|" in str(skills_raw) else ","
        doc["skills"] = [s.strip() for s in str(skills_raw).split(sep) if s.strip()]

        duration_months = doc.get("duration_months") or doc.get("duration") or 1
        doc["duration"] = f"{duration_months} months"

        currency  = doc.get("stipend_currency") or "INR"
        amount    = doc.get("stipend") or 0
        doc["stipend"] = f"{currency} {amount}/mo"

        degree   = doc.get("degree_required") or "any degree"
        exp      = doc.get("experience_required") or "no"
        openings = doc.get("total_openings") or 1
        doc["description"] = (
            doc.get("description")
            or f"Requires {degree} and {exp} experience. Openings: {openings}."
        )
        doc["apply_url"] = doc.get("apply_url") or ""
        doc["deadline"]  = parse_date(doc.get("apply_by"))
        doc["posted_at"] = parse_date(doc.get("posted_on")) or datetime.now(timezone.utc)

        docs.append(doc)

    # Insert in chunks of 1 000
    chunk_size = 1000
    for i in range(0, len(docs), chunk_size):
        chunk = docs[i : i + chunk_size]
        await db.internships.insert_many(chunk)
        print(f"    Inserted chunk {i // chunk_size + 1}  ({len(chunk)} docs)")

    print(f"  [OK]  {len(docs):,} internships imported.\n")
    return len(docs)


async def import_users(db):
    """Load user_training_data.csv and insert into MongoDB."""
    print(f"  Reading {USER_CSV.name} ...")

    if not USER_CSV.exists():
        print(f"  [ERR]  File not found: {USER_CSV}")
        return 0

    df = pd.read_csv(USER_CSV)
    print(f"  Loaded {len(df):,} rows  |  Columns: {df.columns.tolist()}")

    docs = []
    for _, row in df.iterrows():
        doc = row.where(pd.notna(row), None).to_dict()

        doc["name"]  = doc.get("name") or "Unknown User"
        doc["email"] = str(doc.get("email") or "").lower()

        # Hash password — use fast rounds (4) for bulk import speed
        raw_pw = str(doc.get("password") or "password123")
        doc["password_hash"] = bcrypt.hashpw(
            raw_pw.encode("utf-8"), bcrypt.gensalt(rounds=4)
        ).decode("utf-8")
        doc.pop("password", None)   # never store plain text

        skills_raw = doc.get("skills") or ""
        doc["skills"] = [s.strip() for s in str(skills_raw).split(",") if s.strip()]

        interests_raw = doc.get("interests") or ""
        doc["interests"] = [s.strip() for s in str(interests_raw).split(",") if s.strip()]

        doc["cgpa"] = float(doc.get("cgpa") or 0.0)
        doc["preferred_location"] = doc.get("preferred_location") or "Any"
        doc["preferred_type"]     = doc.get("preferred_type")     or "Any"
        doc["graduation_year"]    = int(doc.get("graduation_year") or 2025)
        doc["role"]               = doc.get("role") or "student"
        doc["created_at"]         = datetime.now(timezone.utc)

        docs.append(doc)

    chunk_size = 1000
    for i in range(0, len(docs), chunk_size):
        chunk = docs[i : i + chunk_size]
        await db.users.insert_many(chunk)
        print(f"    Inserted chunk {i // chunk_size + 1}  ({len(chunk)} docs)")

    print(f"  [OK]  {len(docs):,} users imported.\n")
    return len(docs)


async def import_real_data():
    """Connect to MongoDB and import both CSVs."""
    print(f"\n{DIVIDER}")
    print("STEP 2  ->  IMPORTING REAL DATA FROM CSV FILES")
    print(DIVIDER)

    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DB_NAME]

    n_internships = await import_internships(db)
    n_users       = await import_users(db)

    client.close()
    return n_internships, n_users


# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Retrain the Random Forest model
# ─────────────────────────────────────────────────────────────────────────────

def build_training_data():
    """Build (X, y) from user_training_data.csv."""
    if not USER_CSV.exists():
        print(f"  [ERR]  {USER_CSV} not found - cannot train!")
        return None, None

    users = pd.read_csv(USER_CSV)
    print(f"  Loaded {len(users):,} user profiles for training")

    X, y = [], []
    skipped = 0

    for idx, user in users.iterrows():
        try:
            skills_str    = str(user.get("skills") or "")
            interests_str = str(user.get("interests") or "")

            skills    = [s.strip() for s in skills_str.split(",")    if s.strip()]
            interests = [s.strip() for s in interests_str.split(",") if s.strip()]

            cgpa = float(user.get("cgpa") or 7.5)
            cgpa = max(0.0, min(10.0, cgpa))

            location = str(user.get("preferred_location") or "Remote").strip()
            type_    = str(user.get("preferred_type")     or "Hybrid").strip()

            # ── Infer target domain from interests ────────────────────────────
            preferred_domain = "Web"   # default fallback

            if interests:
                # Direct match against known domains
                for interest in interests:
                    for domain in ALL_DOMAINS:
                        if (domain.lower() in interest.lower()
                                or interest.lower() in domain.lower()):
                            preferred_domain = domain
                            break
                    if preferred_domain != "Web":
                        break

                # If still default, try raw interest as domain name
                if preferred_domain == "Web" and interests:
                    candidate = interests[0]
                    # fuzzy check
                    for domain in ALL_DOMAINS:
                        if domain.lower() in candidate.lower():
                            preferred_domain = domain
                            break

            # Validate domain is known
            if preferred_domain not in ALL_DOMAINS:
                preferred_domain = "Web"

            vec = build_feature_vector(skills, cgpa, interests, location, type_)
            X.append(vec)
            y.append(preferred_domain)

            if (idx + 1) % 500 == 0:
                print(f"    Processed {idx + 1:,} users ...")

        except Exception as exc:
            skipped += 1

    print(f"  [OK]  Built {len(X):,} training samples  (skipped {skipped})")
    if not X:
        return None, None

    return np.array(X), np.array(y)


def train_and_save(X, y):
    """Train RandomForest and persist artifacts."""
    print(f"\n  Training RandomForestClassifier ...")

    # Stratified split — 80 / 20
    unique_classes, counts = np.unique(y, return_counts=True)
    # Only stratify if every class has >= 2 samples
    can_stratify = all(c >= 2 for c in counts)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=0.2,
        random_state=42,
        stratify=y if can_stratify else None,
    )

    print(f"  Train: {X_train.shape[0]:,}  |  Test: {X_test.shape[0]:,}")
    print(f"  Classes: {list(unique_classes)}\n")

    clf = RandomForestClassifier(
        n_estimators=300,
        max_depth=25,
        min_samples_split=5,
        min_samples_leaf=2,
        class_weight="balanced",
        n_jobs=-1,
        random_state=42,
        verbose=1,
    )
    clf.fit(X_train, y_train)

    # ── Accuracy ──────────────────────────────────────────────────────────────
    train_acc = accuracy_score(y_train, clf.predict(X_train))
    test_acc  = accuracy_score(y_test,  clf.predict(X_test))

    print(f"\n  Training Accuracy : {train_acc * 100:.2f}%")
    print(f"  Test     Accuracy : {test_acc  * 100:.2f}%")
    print("\n  Classification Report (test set):")
    print(classification_report(y_test, clf.predict(X_test), zero_division=0))

    # ── Save artifacts ────────────────────────────────────────────────────────
    ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)
    joblib.dump(clf, MODEL_PATH)
    joblib.dump({"domains": ALL_DOMAINS, "skills": ALL_SKILLS}, ENCODER_PATH)

    print(f"  [SAVED]  Model    -> {MODEL_PATH}")
    print(f"  [SAVED]  Encoders -> {ENCODER_PATH}")
    return test_acc


def retrain_model():
    """Build data and train the RF model."""
    print(f"\n{DIVIDER}")
    print("STEP 3  ->  RETRAINING RANDOM FOREST MODEL")
    print(DIVIDER)

    X, y = build_training_data()
    if X is None:
        print("  [ERR]  Cannot train - no data available!")
        return

    acc = train_and_save(X, y)
    print(f"\n  Final Test Accuracy: {acc * 100:.2f}%")


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

async def async_main():
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DB_NAME]

    # STEP 1 — wipe everything
    await nuke_database(db)
    client.close()

    # STEP 2 — import real data
    n_int, n_usr = await import_real_data()

    return n_int, n_usr


def main():
    print(f"\n{'#' * 70}")
    print("#  INTERNMATCH — FULL RESET + REAL DATA IMPORT + MODEL RETRAIN   #")
    print(f"{'#' * 70}\n")
    print(f"  MongoDB DB  : {settings.MONGODB_DB_NAME}")
    print(f"  Internships : {INTERNSHIP_CSV.name}")
    print(f"  Users       : {USER_CSV.name}")
    print(f"  Model out   : {MODEL_PATH}")

    # Run async DB steps
    n_int, n_usr = asyncio.run(async_main())

    # STEP 3 — retrain (synchronous sklearn)
    retrain_model()

    # Final summary
    print(f"\n{'#' * 70}")
    print("#  ALL DONE!                                                       #")
    print(f"{'#' * 70}")
    print(f"\n  Internships imported : {n_int:,}")
    print(f"  Users imported       : {n_usr:,}")
    print(f"  Model artifacts      : {MODEL_PATH}")
    print(f"\n  >> Restart your FastAPI server to load the new model!\n")


if __name__ == "__main__":
    main()
