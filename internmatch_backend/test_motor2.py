import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def main():
    try:
        url = 'mongodb+srv://dipesh:dipesh123@internmatch.nlwzx35.mongodb.net/?retryWrites=true&w=majority&appName=InternMatch&tlsInsecure=true'
        client2 = AsyncIOMotorClient(url, serverSelectionTimeoutMS=5000)
        await client2.admin.command('ping')
        print('Ping async success with default loop policy')
    except Exception as e:
        print('Failed default loop', repr(e))

asyncio.run(main())
