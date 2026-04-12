import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import sys

async def main():
    try:
        url = 'mongodb+srv://dipesh:dipesh123@internmatch.nlwzx35.mongodb.net/?retryWrites=true&w=majority&appName=InternMatch&tlsAllowInvalidCertificates=true'
        client = AsyncIOMotorClient(url, serverSelectionTimeoutMS=5000)
        await client.admin.command('ping')
        print('Ping async success with tlsAllowInvalidCertificates')
    except Exception as e:
        print('Failed tlsAllowInvalidCertificates', repr(e))

    try:
        url = 'mongodb+srv://dipesh:dipesh123@internmatch.nlwzx35.mongodb.net/?retryWrites=true&w=majority&appName=InternMatch&tlsInsecure=true'
        client2 = AsyncIOMotorClient(url, serverSelectionTimeoutMS=5000)
        await client2.admin.command('ping')
        print('Ping async success with tlsInsecure')
    except Exception as e:
        print('Failed tlsInsecure', repr(e))

if sys.platform == 'win32':
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
asyncio.run(main())
