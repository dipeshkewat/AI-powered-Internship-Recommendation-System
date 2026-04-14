import asyncio
import sys
import pandas as pd
from datetime import datetime, timezone
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings
from app.core.security import hash_password
import bcrypt

INTERNSHIP_CSV = Path(__file__).resolve().parent.parent / "internship_listings_10000.csv"
USER_CSV = Path(__file__).resolve().parent.parent / "user_training_data.csv"

def parse_date(date_str):
    if pd.isna(date_str):
        return None
    try:
        return datetime.strptime(str(date_str), "%Y-%m-%d").replace(tzinfo=timezone.utc)
    except Exception:
        return None

async def import_data():
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DB_NAME]

    print("Connected to MongoDB Atlas...")

    # Wipe existing data for a clean import
    await db.internships.delete_many({})
    await db.users.delete_many({})
    print("Cleared existing internships and users collections.")

    # 1. Process and Import Internships
    print(f"Reading {INTERNSHIP_CSV}...")
    df_internships = pd.read_csv(INTERNSHIP_CSV)
    
    internship_docs = []
    for _, row in df_internships.iterrows():
        # Keep original row data
        doc = row.where(pd.notna(row), None).to_dict()
        
        # Map to Pydantic Schema Fields
        doc["title"] = doc.get("internship_title", "Unknown Title")
        doc["company"] = doc.get("company", "Unknown Company")
        doc["company_logo"] = "" # You can fallback to ui-avatars later if needed
        doc["location"] = doc.get("location", "Remote")
        doc["type"] = doc.get("mode", "Remote")
        
        skills_str = doc.get("required_skills", "")
        doc["skills"] = [s.strip() for s in str(skills_str).split("|") if s.strip()] if skills_str else []
        
        doc["duration"] = f"{doc.get('duration_months', 1)} months"
        doc["stipend"] = f"{doc.get('stipend_currency', 'INR')} {doc.get('stipend', '0')}/mo"
        doc["domain"] = doc.get("domain", "General")
        
        doc["description"] = f"Requires {doc.get('degree_required', 'any degree')} and {doc.get('experience_required', 'no')} experience. Openings: {doc.get('total_openings', 1)}."
        doc["apply_url"] = ""
        
        doc["deadline"] = parse_date(doc.get("apply_by"))
        doc["posted_at"] = parse_date(doc.get("posted_on"))

        # Add all fields and make sure no pandas NaNs
        # NaN is already converted to None by where/to_dict
        internship_docs.append(doc)

    print(f"Importing {len(internship_docs)} internships in chunks...")
    # Insert in chunks of 1000
    chunk_size = 1000
    for i in range(0, len(internship_docs), chunk_size):
        chunk = internship_docs[i:i + chunk_size]
        await db.internships.insert_many(chunk)
    print(f"Successfully inserted {len(internship_docs)} internships.")

    # 2. Process and Import Users
    print(f"Reading {USER_CSV}...")
    df_users = pd.read_csv(USER_CSV)
    
    # Pre-calculate default password hash to speed up insertion
    default_password_hash = hash_password("password123")
    
    user_docs = []
    for _, row in df_users.iterrows():
        # Keep original row data
        doc = row.where(pd.notna(row), None).to_dict()
        
        # Map fields
        doc["name"] = doc.get("name", "Unknown User")
        doc["email"] = doc.get("email", "").lower()
        
        # Hash user passwords before insertion to maintain authentication security
        raw_pw = doc.get("password")
        plain_password = str(raw_pw) if raw_pw else "password123"
        
        # Use fast bcrypt (rounds=4) for bulk mock data import
        fast_hash = bcrypt.hashpw(plain_password.encode("utf-8"), bcrypt.gensalt(rounds=4)).decode("utf-8")
        doc["password_hash"] = fast_hash
            
        # remove plain text password from being stored
        if "password" in doc:
            del doc["password"]
            
        skills_str = doc.get("skills", "")
        doc["skills"] = [s.strip() for s in str(skills_str).split(",") if s.strip()] if skills_str else []
        
        interests_str = doc.get("interests", "")
        doc["interests"] = [s.strip() for s in str(interests_str).split(",") if s.strip()] if interests_str else []
        
        doc["cgpa"] = float(doc.get("cgpa", 0.0)) if doc.get("cgpa") is not None else 0.0
        doc["preferred_location"] = doc.get("preferred_location", "Any")
        doc["preferred_type"] = doc.get("preferred_type", "Any")
        doc["graduation_year"] = int(doc.get("graduation_year", 2025)) if doc.get("graduation_year") is not None else 2025
        
        user_docs.append(doc)

    print(f"Importing {len(user_docs)} users in chunks...")
    for i in range(0, len(user_docs), chunk_size):
        chunk = user_docs[i:i + chunk_size]
        await db.users.insert_many(chunk)
        
    print(f"Successfully inserted {len(user_docs)} users.")
    
    client.close()
    print("Database migration complete.")

if __name__ == "__main__":
    asyncio.run(import_data())
