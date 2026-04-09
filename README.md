# 🎯 InternMatch — AI-Powered Internship Recommendation System

<div align="center">

![InternMatch Banner](https://img.shields.io/badge/InternMatch-AI%20Powered-6C63FF?style=for-the-badge&logo=sparkles&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=for-the-badge&logo=scikitlearn&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB%20Atlas-47A248?style=for-the-badge&logo=mongodb&logoColor=white)

**Match students to internships they'll actually love — powered by machine learning.**

[Features](#-features) • [Architecture](#-architecture) • [Tech Stack](#-tech-stack) • [Setup](#-setup) • [API Docs](#-api-reference) • [ML Model](#-ml-model)

</div>

---

## 📌 Overview

**InternMatch** is an AI-powered internship recommendation system that intelligently matches engineering students with relevant internship opportunities based on their skills, interests, academic background, and preferences.

Unlike simple keyword-based filters, InternMatch uses a **Random Forest classifier** trained on a **45-dimensional feature vector** to deliver personalized, ranked recommendations — surfacing opportunities that align with both hard skills and soft preferences.

> Built as a full-stack project: a **Flutter mobile app** (frontend) paired with a **FastAPI + scikit-learn** backend, persisted in **MongoDB Atlas**.

---

## ✨ Features

- 🤖 **AI Recommendations** — Random Forest model ranks internships by compatibility score
- 👤 **Smart Profiling** — Students fill a structured profile (skills, domain, location, stipend, duration preferences)
- 📊 **Match Score** — Each internship is shown with a calibrated match percentage
- 🔍 **Filter & Search** — Domain, location, stipend, duration, and remote/hybrid filters
- 📱 **Flutter Mobile App** — Full-screen, production-quality UI with Riverpod state management
- 🔒 **Auth System** — Secure JWT-based student authentication
- 📬 **Internship Listings** — Companies can post opportunities via the admin panel
- ⚡ **Fast API** — Sub-100ms inference with pre-loaded scikit-learn model via joblib

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────┐
│               Flutter Frontend                  │
│  (Riverpod • go_router • Dio • Material 3)      │
└──────────────────────┬──────────────────────────┘
                       │ REST API (JSON)
┌──────────────────────▼──────────────────────────┐
│              FastAPI Backend                     │
│  ┌────────────────┐   ┌────────────────────┐    │
│  │  Auth Router   │   │  Recommend Router  │    │
│  └────────────────┘   └────────┬───────────┘    │
│                                │                │
│                   ┌────────────▼────────────┐   │
│                   │   ML Inference Engine   │   │
│                   │  Random Forest (joblib) │   │
│                   │  45-dim Feature Vector  │   │
│                   └────────────────────────┘   │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│              MongoDB Atlas                       │
│  users • internships • applications • models    │
└─────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.x, Riverpod, go_router, Dio |
| **Backend** | Python 3.11, FastAPI, Uvicorn |
| **ML** | scikit-learn (Random Forest), pandas, joblib |
| **Database** | MongoDB Atlas, Motor (async driver) |
| **Auth** | JWT (python-jose), bcrypt |
| **Deployment** | Render / Railway (backend), Play Store / APK (app) |

---

## 📁 Project Structure

```
internmatch/
│
├── backend/                        # FastAPI backend
│   ├── app/
│   │   ├── main.py                 # App entry point
│   │   ├── config.py               # Environment config
│   │   ├── routers/
│   │   │   ├── auth.py             # Login / Register
│   │   │   ├── recommend.py        # ML recommendation endpoint
│   │   │   └── internships.py      # CRUD for listings
│   │   ├── models/
│   │   │   ├── user.py             # Pydantic models
│   │   │   └── internship.py
│   │   ├── ml/
│   │   │   ├── train.py            # Model training script
│   │   │   ├── predict.py          # Inference pipeline
│   │   │   ├── feature_engineering.py  # 45-dim vector builder
│   │   │   └── artifacts/
│   │   │       ├── model.joblib    # Trained RF classifier
│   │   │       └── encoders.joblib # Label encoders
│   │   └── database.py             # MongoDB Atlas connection
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/                       # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── theme/              # Indigo/purple design system
│   │   │   ├── router/             # go_router config
│   │   │   └── network/            # Dio client + interceptors
│   │   ├── features/
│   │   │   ├── auth/               # Login, Register screens
│   │   │   ├── profile/            # Student profile builder
│   │   │   ├── recommendations/    # Match feed
│   │   │   └── internship_detail/  # Detail + apply screen
│   │   └── providers/              # Riverpod providers
│   └── pubspec.yaml
│
└── README.md
```

---

## 🤖 ML Model

### Feature Engineering (45 Dimensions)

The recommendation engine encodes student profiles and internship listings into a shared 45-dimensional feature vector:

| Category | Features | Dimensions |
|----------|----------|------------|
| **Skills** | One-hot encoded skill tags (top 20) | 20 |
| **Domain** | Encoded domain/sector preference | 5 |
| **Location** | Remote preference, city encoding | 4 |
| **Academic** | CGPA band, branch encoding | 4 |
| **Preferences** | Stipend range, duration, part/full time | 6 |
| **Behavioral** | Past applications, profile completeness | 3 |
| **Temporal** | Semester, urgency signals | 3 |

### Model

- **Algorithm**: Random Forest Classifier (scikit-learn)
- **Training**: Labeled match/no-match pairs from internship applications
- **Output**: Match probability score (0–1) → converted to percentage
- **Persistence**: `joblib` artifacts loaded at FastAPI startup for zero-latency inference

### Training

```bash
cd backend
python -m app.ml.train --data data/dataset.csv --output app/ml/artifacts/
```

---

## ⚙️ Setup

### Prerequisites

- Python 3.11+
- Flutter 3.x SDK
- MongoDB Atlas account (free tier works)

### Backend

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/internmatch.git
cd internmatch/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# → Fill in MONGO_URI, JWT_SECRET, etc.

# Run the server
uvicorn app.main:app --reload --port 8000
```

### Frontend

```bash
cd internmatch/frontend

# Install Flutter packages
flutter pub get

# Configure API base URL in lib/core/network/api_client.dart

# Run on device/emulator
flutter run
```

---

## 🔌 API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/auth/register` | Register a new student |
| `POST` | `/auth/login` | Login → returns JWT |
| `GET` | `/internships/` | List all internships |
| `GET` | `/internships/{id}` | Get internship details |
| `POST` | `/recommend/` | Get AI recommendations for a student |
| `PUT` | `/profile/` | Update student profile |

### Sample: Recommendation Request

```json
POST /recommend/
Authorization: Bearer <token>

{
  "student_id": "abc123",
  "top_k": 10
}
```

```json
// Response
{
  "recommendations": [
    {
      "internship_id": "xyz789",
      "title": "ML Engineer Intern",
      "company": "TechCorp",
      "match_score": 0.87,
      "location": "Remote",
      "stipend": 15000,
      "duration": "3 months"
    }
  ]
}
```

Interactive docs available at: `http://localhost:8000/docs`

---

## 📸 Screenshots

> *(Add your Flutter app screenshots here)*

| Onboarding | Recommendations Feed | Internship Detail |
|:---:|:---:|:---:|
| ![](screenshots/onboarding.png) | ![](screenshots/feed.png) | ![](screenshots/detail.png) |

---

## 🗺 Roadmap

- [x] Random Forest recommendation engine
- [x] FastAPI backend with JWT auth
- [x] Flutter UI with Riverpod state management
- [x] MongoDB Atlas integration
- [ ] Resume parsing for auto-profile fill
- [ ] Email/OTP verification
- [ ] Company-side dashboard (web)
- [ ] Push notifications for new matches
- [ ] Model retraining pipeline (scheduled)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 👨‍💻 Author

**Dipesh** — Junior AI Trainee @ Compozent | Engineering Student @ SLRTCE, Mumbai

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/YOUR_PROFILE)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/YOUR_USERNAME)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Built with 💙 using Flutter + FastAPI + scikit-learn</sub>
</div>
