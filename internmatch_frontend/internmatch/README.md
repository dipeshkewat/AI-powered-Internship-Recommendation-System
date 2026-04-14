# InternMatch — Flutter Frontend (Production-Ready)

AI-powered internship recommendation app. Dark, minimal UI backed by FastAPI + ML.

---

## Stack

| Layer | Tech |
|-------|------|
| Framework | Flutter 3.x |
| State | Riverpod 2.x (`StateNotifierProvider`) |
| HTTP | Dio 5.x |
| Animations | flutter_animate |
| Routing | go_router (configured, swap in when needed) |
| Models | freezed + json_serializable |
| Fonts | DM Sans (Google Fonts) |

---

## Project Structure

```
lib/
├── main.dart                    # Entry point, ProviderScope
├── theme/
│   └── app_theme.dart           # AppColors, AppTheme (dark)
├── models/
│   ├── internship.dart          # Internship model + dummy data
│   └── user_profile.dart        # UserProfile model
├── services/
│   └── api_service.dart         # All API calls (Dio), falls back to dummy data
├── providers/
│   └── app_providers.dart       # Auth, Profile, Recommendations, Search, Bookmarks
├── widgets/
│   └── shared_widgets.dart      # GradientButton, AppTextField, InternshipCard, etc.
└── screens/
    ├── welcome_screen.dart
    ├── auth_screen.dart          # Login + Register tabs
    ├── profile_screen.dart       # ML input form (skills, CGPA, interests)
    ├── main_shell.dart           # Bottom nav shell
    ├── dashboard_screen.dart     # Stats + top picks
    ├── recommendation_screen.dart # Full ML results with domain filter
    └── search_screen.dart        # Live search + type/domain filters
```

---

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate freezed code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Connect your backend

In `lib/services/api_service.dart`, update:

```dart
const String _baseUrl = 'http://YOUR_FASTAPI_IP:8000/api/v1';
```

The app **runs fully offline with dummy data** until you connect the backend.

### 4. Run

```bash
flutter run
```

---

## Connecting the ML Model

The recommendation endpoint expects:

```json
POST /api/v1/recommendations
{
  "skills": ["Flutter", "Python"],
  "cgpa": 8.5,
  "interests": ["AI/ML", "App Dev"],
  "preferred_location": "Bangalore",
  "preferred_type": "Remote"
}
```

Response format:

```json
{
  "recommendations": [
    {
      "id": "...",
      "title": "...",
      "company": "...",
      "match_score": 92,
      ...
    }
  ]
}
```

---

## Key Patterns

- **Offline-first**: All API calls in `ApiService` have `catch` blocks that fall back to dummy data.
- **Riverpod separation**: Each feature (auth, profile, recs, search, bookmarks) has its own `StateNotifier`.
- **Animated cards**: `InternshipCard` uses `flutter_animate` with staggered delays.
- **ML-ready profile form**: `ProfileScreen` collects exactly the features your Random Forest expects.
- **No hardcoded user names**: Profile name flows through `profileProvider`.

---

## TODO before submission

- [ ] Run `build_runner` to generate `.freezed.dart` and `.g.dart` files
- [ ] Replace `_baseUrl` with actual FastAPI endpoint
- [ ] Add JWT token persistence in `SharedPreferences`
- [ ] Add internship detail screen
- [ ] Add Google/GitHub OAuth (stubs are present in auth_screen)
