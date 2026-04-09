# 🚀 InternMatch Quick-Start Guide

## Prerequisites
- Docker & Docker Compose installed
- Flutter SDK (for frontend)
- Git (optional)

---

## 🔧 Complete Setup & Run

### Option 1: Everything with Docker (Recommended)

```bash
# 1. Navigate to backend directory
cd internmatch_backend

# 2. Create .env file from template
cp .env.example .env

# 3. Start MongoDB + FastAPI with Docker Compose
docker-compose up

# Output:
# - MongoDB running on localhost:27017
# - FastAPI running on localhost:8000
# - Health check: curl http://localhost:8000/health
```

### Option 2: Backend Manual Setup (if Docker issues)

```bash
# 1. Install MongoDB locally
# - Windows: Download from https://www.mongodb.com/try/download/community
# - Mac: brew install mongodb-community
# - Linux: apt-get install mongodb

# 2. Start MongoDB service
# - Windows: mongod (or use MongoDB Compass)
# - Mac: brew services start mongodb-community
# - Linux: sudo systemctl start mongod

# 3. Create Python virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Create .env file
cp .env.example .env

# 6. Run FastAPI development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Output:
# INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

### Frontend Setup & Run

```bash
# 1. Navigate to frontend directory
cd internmatch

# 2. Get Flutter dependencies
flutter pub get

# 3. Run on Chrome (for preview)
flutter run -d chrome

# OR run on Android/iOS if emulator setup
flutter run -d android
flutter run -d ios

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
# Stop: Press 'q' in terminal
```

---

## 🧪 Testing the Connections

### 1. Test Backend Health
```bash
curl http://localhost:8000/health
# Expected: {"status":"ok","version":"1.0.0"}
```

### 2. Test Database Connection
```bash
# Via Docker
docker exec internmatch_mongo mongo --eval "db.adminCommand('ping')"

# Or in MongoDB Compass:
# Connect to: mongodb://localhost:27017
```

### 3. Test ML Model
```bash
curl -X POST http://localhost:8000/api/v1/recommendations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "skills": ["Flutter", "Python"],
    "cgpa": 8.5,
    "interests": ["AI/ML"],
    "preferred_location": "Bangalore",
    "preferred_type": "Remote"
  }'
```

### 4. Test Frontend Connection
```
1. Open Flutter app in Chrome
2. Navigate to Auth screen
3. Register with test credentials
4. Verify token stored in browser localStorage
5. Complete onboarding
6. View recommendations (should call ML endpoint)
```

---

## 🐛 Troubleshooting

### Issue: "Connection refused" on port 8000
**Solution:**
```bash
# Check if port is in use
lsof -i :8000  # Mac/Linux
netstat -ano | findstr :8000  # Windows

# Kill process (if needed)
kill -9 <PID>  # Mac/Linux
taskkill /PID <PID> /F  # Windows

# Start backend again
uvicorn app.main:app --reload
```

### Issue: MongoDB connection error
**Solution:**
```bash
# Start MongoDB
mongod  # Or via docker-compose

# Verify connection
mongo --eval "db.adminCommand('ping')"

# Check logs
tail -f /usr/local/var/log/mongodb/mongo.log  # Mac
```

### Issue: Flask/FastAPI not reloading changes
**Solution:**
```bash
# Stop (Ctrl+C) and restart with:
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Issue: Flutter can't reach backend
**Solution:**
```bash
# 1. Verify backend is running
curl http://localhost:8000/health

# 2. Check API base URL in code:
# lib/services/api_service.dart
# Should be: http://localhost:8000/api/v1

# 3. Check CORS is enabled (should be in console logs)

# 4. For web, use:
# http://127.0.0.1:8000 OR http://localhost:8000
```

---

## 📊 Architecture in Action

```
┌────────────────────────────────────────────┐
│         Flutter App (Chrome)               │
│  ┌─────────────────────────────────────┐  │
│  │ Riverpod State Management           │  │
│  │ Go Router Navigation                │  │
│  │ Dio HTTP Client (JWT auth)          │  │
│  └──────────────┬──────────────────────┘  │
│                 │                         │
│                 │ HTTP Requests           │
│                 │ (JSON + Bearer Token)   │
│                 ▼                         │
│                 
├────────────────────────────────────────────┤
│
│  ┌────────────────────────────────────┐
│  │    FastAPI Backend (8000)          │
│  │  ┌──────────────────────────────┐ │
│  │  │ JWT Auth Middleware          │ │
│  │  │ CORS Headers                 │ │
│  │  │ Route Handlers               │ │
│  │  └──────────┬───────────────────┘ │
│  │             │                      │
│  │  ┌──────────▼───────────────────┐ │
│  │  │  ML Recommendation Engine    │ │
│  │  │  (Random Forest Model)       │ │
│  │  │  ┌─────────────────────┐    │ │
│  │  │  │ rf_model.joblib    │    │ │
│  │  │  │ encoders.joblib    │    │ │
│  │  │  └─────────────────────┘    │ │
│  │  └──────────┬───────────────────┘ │
│  │             │                      │
│  │  ┌──────────▼───────────────────┐ │
│  │  │ Business Logic Services      │ │
│  │  │ - Auth Service               │ │
│  │  │ - User Service               │ │
│  │  │ - Internship Service         │ │
│  │  │ - Recommendation Service     │ │
│  │  └──────────┬───────────────────┘ │
│  └─────────────┼────────────────────┘
│                │
│                │ Async Motor Driver
│                ▼
│
├────────────────────────────────────────────┤
│
│  ┌────────────────────────────────────┐
│  │    MongoDB (27017)                 │
│  │  ┌──────────────────────────────┐ │
│  │  │ Collections:                 │ │
│  │  │ - users                      │ │
│  │  │ - internships                │ │
│  │  │ - bookmarks                  │ │
│  │  │ - applications               │ │
│  │  │ - recommendations (cache)    │ │
│  │  └──────────────────────────────┘ │
│  └────────────────────────────────────┘
│
└────────────────────────────────────────────┘
```

---

## 📋 Configuration Files

### Frontend (internmatch/lib/services/api_service.dart)
```dart
const String _baseUrl = 'http://localhost:8000/api/v1';
```

### Backend (.env)
```env
APP_ENV=development
APP_HOST=0.0.0.0
APP_PORT=8000
MONGODB_URL=mongodb://localhost:27017
MONGODB_DB_NAME=internmatch
MODEL_PATH=app/ml/artifacts/rf_model.joblib
ENCODER_PATH=app/ml/artifacts/encoders.joblib
```

### Docker Compose (internmatch_backend/docker-compose.yml)
```yaml
services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - MONGODB_URL=mongodb://mongo:27017
  
  mongo:
    image: mongo:7.0
    ports:
      - "27017:27017"
```

---

## 🎯 User Journey Test Flow

1. **Open App**
   - Splash screen (1.8s)
   - Routes to Welcome screen

2. **Register/Login**
   - Enter credentials
   - Backend validates + returns JWT token
   - Frontend stores token in SharedPreferences

3. **Complete Onboarding** 
   - 11-step wizard collects profile data
   - Data stored in SharedPreferences

4. **View Dashboard**
   - Main shell with 5 tabs
   - Shows trending internships (mock data)
   - Shows "Get Recommendations" button

5. **Get ML Recommendations**
   - Click "Get Recommendations"
   - Frontend sends profile data to backend
   - ML model ranks internships
   - Backend returns matched list
   - Frontend displays results

6. **Interact with Internships**
   - Click card → View details
   - Bookmark/Remove bookmark
   - Apply to internship

7. **Track Activity**
   - View bookmarks
   - View applications
   - Update profile

---

## 📚 Key Files to Monitor

**Frontend**
- `lib/services/api_service.dart` — HTTP requests
- `lib/providers/app_providers.dart` — State management
- `lib/utils/app_router.dart` — Navigation logic

**Backend**
- `app/main.py` — FastAPI setup + ML loading
- `app/services/recommendation_service.py` — ML orchestration
- `app/db/database.py` — MongoDB connection

**Configuration**
- `internmatch_backend/.env` — Environment variables
- `docker-compose.yml` — Docker services
- `internmatch/pubspec.yaml` — Frontend dependencies
- `internmatch_backend/requirements.txt` — Backend dependencies

---

## ✅ Verification Commands

```bash
# Backend health
curl http://localhost:8000/health

# ML model loaded
curl http://localhost:8000/docs  # Check in Swagger UI

# Database running
docker ps | grep mongo
# OR
mongosh --eval "db.adminCommand('ping')"

# Frontend compiled
flutter pub get
flutter analyze

# All good? Test end-to-end
# 1. Start docker-compose (backend)
# 2. Run flutter (frontend)
# 3. Register → Onboard → Test ML recommendations
```

---

## 🎓 Next Steps

1. **Seed Database** (Optional)
   ```bash
   python scripts/seed_db.py
   # Adds sample internships to MongoDB
   ```

2. **Train ML Model** (Optional, model already exists)
   ```bash
   python scripts/train_model.py
   # Trains RandomForest on CSV data
   ```

3. **Run Tests**
   ```bash
   pytest tests/
   ```

4. **Deploy**
   - See DEPLOYMENT.md for production setup

---

**Status**: ✅ Ready to run  
**Last Updated**: April 9, 2026
