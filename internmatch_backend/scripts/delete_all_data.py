import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

load_dotenv()

async def delete_all_data():
    mongo_url = os.getenv("MONGODB_URL")
    db_name = os.getenv("MONGODB_DB_NAME", "internmatch")
    
    if not mongo_url:
        print("MONGODB_URL not found in .env")
        return
        
    print(f"Connecting to MongoDB...")
    client = AsyncIOMotorClient(mongo_url)
    db = client[db_name]
    
    collections = await db.list_collection_names()
    print(f"Collections found in {db_name}: {collections}")
    
    for coll in collections:
        result = await db[coll].delete_many({})
        print(f"Deleted {result.deleted_count} documents from {coll}")
        
    print("All data deleted from the database.")

if __name__ == "__main__":
    asyncio.run(delete_all_data())
