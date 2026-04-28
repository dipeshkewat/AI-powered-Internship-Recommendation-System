import asyncio
import sys
import pandas as pd
from datetime import datetime, timezone
from pathlib import Path
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

load_dotenv()

from app.core.config import settings

INTERNSHIP_CSV_1 = Path(__file__).resolve().parent.parent / "internships.csv"
INTERNSHIP_CSV_2 = Path(__file__).resolve().parent.parent / "internships_1777226980.csv"

async def import_data():
    mongo_url = os.getenv("MONGODB_URL")
    db_name = os.getenv("MONGODB_DB_NAME", "internmatch")
    
    if not mongo_url:
        print("MONGODB_URL not found in .env")
        return
        
    client = AsyncIOMotorClient(mongo_url)
    db = client[db_name]

    print("Connected to MongoDB Atlas...")

    # Wipe existing data for internships only
    await db.internships.delete_many({})
    print("Cleared existing internships collection.")

    df1 = pd.read_csv(INTERNSHIP_CSV_1)
    df2 = pd.read_csv(INTERNSHIP_CSV_2)
    
    # Ensure category exists in df2
    if 'category' not in df2.columns:
        df2['category'] = 'General'
        
    # Ensure detail_url exists in df1 and df2
    if 'detail_url' not in df1.columns:
        df1['detail_url'] = ''
    if 'detail_url' not in df2.columns:
        df2['detail_url'] = ''

    df = pd.concat([df1, df2], ignore_index=True)
    print(f"Total rows after concatenation: {len(df)}")
    
    # Drop rows where title is NaN
    df = df.dropna(subset=['title'])
    print(f"Total rows after dropping empty titles: {len(df)}")
    
    internship_docs = []
    for _, row in df.iterrows():
        doc = row.where(pd.notna(row), None).to_dict()
        
        internship = {}
        internship["title"] = doc.get("title", "Unknown Title")
        internship["company"] = doc.get("company", "Unknown Company")
        if not internship["company"]:
            internship["company"] = "Unknown Company"
        internship["company_logo"] = "" 
        
        location = doc.get("location", "Remote")
        if not location:
            location = "Remote"
        internship["location"] = location
        
        loc_lower = str(location).lower()
        if "remote" in loc_lower or "work from home" in loc_lower:
            internship["type"] = "Remote"
        elif "hybrid" in loc_lower:
            internship["type"] = "Hybrid"
        else:
            internship["type"] = "In-office"
        
        skills_str = doc.get("skills", "")
        internship["skills"] = [s.strip() for s in str(skills_str).split(",")] if skills_str and str(skills_str) != "nan" else []
        
        duration = doc.get("duration")
        internship["duration"] = str(duration) if duration else "Not specified"
        
        stipend = doc.get("stipend")
        internship["stipend"] = str(stipend) if stipend else "Unpaid"
        
        category = doc.get("category", "General")
        internship["domain"] = category if category else "General"
        
        description = doc.get("description", "")
        internship["description"] = str(description) if description else ""
        
        apply_url = doc.get("detail_url", "")
        internship["apply_url"] = str(apply_url) if apply_url else ""
        
        internship["deadline"] = None
        internship["posted_at"] = datetime.now(timezone.utc)

        internship_docs.append(internship)

    print(f"Importing {len(internship_docs)} internships...")
    if internship_docs:
        chunk_size = 500
        for i in range(0, len(internship_docs), chunk_size):
            chunk = internship_docs[i:i + chunk_size]
            await db.internships.insert_many(chunk)
        print(f"Successfully inserted {len(internship_docs)} internships.")
    else:
        print("No valid internships to insert.")

    client.close()
    print("Database migration complete.")

if __name__ == "__main__":
    asyncio.run(import_data())
