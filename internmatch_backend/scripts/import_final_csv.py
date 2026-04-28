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

FINAL_CSV = Path(__file__).resolve().parent.parent / "final_training_data.csv"

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

    df = pd.read_csv(FINAL_CSV)
    print(f"Loaded {len(df)} rows from {FINAL_CSV.name}")
    
    internship_docs = []
    for _, row in df.iterrows():
        doc = row.where(pd.notna(row), None).to_dict()
        
        internship = {}
        internship["title"] = str(doc.get("title", "Unknown Title"))
        internship["company"] = str(doc.get("company", "Unknown Company"))
        internship["company_logo"] = "" 
        
        internship["location"] = str(doc.get("location", "Remote"))
        internship["type"] = str(doc.get("type", "Remote"))
        
        skills_str = doc.get("skills", "")
        internship["skills"] = [s.strip() for s in str(skills_str).split(",")] if skills_str and str(skills_str) != "nan" else []
        
        internship["duration"] = str(doc.get("duration", "Not specified"))
        internship["stipend"] = str(doc.get("stipend", "Unpaid"))
        
        category = doc.get("category", "General")
        internship["domain"] = str(category) if category else "General"
        
        internship["description"] = str(doc.get("description", "No description available."))
        internship["apply_url"] = str(doc.get("detail_url", ""))
        
        internship["deadline"] = None
        internship["posted_at"] = datetime.now(timezone.utc)

        internship_docs.append(internship)

    print(f"Importing {len(internship_docs)} internships...")
    if internship_docs:
        chunk_size = 500
        for i in range(0, len(internship_docs), chunk_size):
            chunk = internship_docs[i:i + chunk_size]
            await db.internships.insert_many(chunk)
        print(f"Successfully inserted {len(internship_docs)} internships into MongoDB.")
    else:
        print("No valid internships to insert.")

    client.close()
    print("Database migration complete.")

if __name__ == "__main__":
    asyncio.run(import_data())
