import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import settings

async def main():
    client = AsyncIOMotorClient(settings.MONGODB_URL)
    db = client[settings.MONGODB_DB_NAME]
    print('Internships count:', await db.internships.count_documents({}))
    print('Users count:', await db.users.count_documents({}))
    client.close()

if __name__ == "__main__":
    asyncio.run(main())
