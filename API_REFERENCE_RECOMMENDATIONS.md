# API Reference - Recommendations Endpoint

## POST /api/v1/recommendations

**Purpose**: Get AI-powered internship recommendations for a user

### Request Body
```json
{
  "skills": ["Python", "React"],
  "cgpa": 8.5,
  "interests": ["Web", "AI/ML"],
  "preferred_location": "Bangalore, India",
  "preferred_type": "Remote",
  "top_n": 10
}
```

### Request Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `skills` | array | Yes | - | User's technical skills |
| `cgpa` | float | Yes | - | GPA (0.0-10.0) |
| `interests` | array | No | `[]` | Career interests/domains |
| `preferred_location` | string | No | `""` | Preferred work location |
| `preferred_type` | string | No | `"Any"` | Remote/Hybrid/On-site |
| `top_n` | int | No | `10` | Number of recommendations (1-30) |

### Response (Success)
```json
{
  "recommendations": [
    {
      "id": "123abc",
      "title": "Senior Full Stack Engineer",
      "company": "Google",
      "company_logo": "https://...",
      "location": "Bangalore, India",
      "type": "Remote",
      "skills": ["Python", "React", "Node.js"],
      "duration": "6 months",
      "stipend": "₹1,00,000/month",
      "domain": "Web",
      "description": "...",
      "apply_url": "https://...",
      "deadline": "2024-12-31T23:59:59",
      "posted_at": "2024-01-15T10:30:00",
      "match_score": 85,
      "is_bookmarked": false,
      "has_applied": false
    },
    ...
  ]
}
```

### Response Status Codes
| Code | Meaning |
|------|---------|
| `200` | Success - recommendations returned |
| `400` | Bad request - invalid parameters |
| `401` | Unauthorized - authentication required |
| `500` | Server error - processing failed |

### Special Cases

#### Empty Profile (No skills/interests)
```json
Request:
{
  "skills": [],
  "cgpa": 0.0,
  "interests": [],
  "preferred_location": "",
  "preferred_type": "Any",
  "top_n": 5
}

Response: Returns 5 random internships with match_score between 60-80%
```

#### No Database Data
```json
Request: (any valid request)

Response:
{
  "recommendations": []
}
(Empty array if no internships in database)
```

### Examples

#### Example 1: Web Developer
```bash
curl -X POST http://localhost:8000/api/v1/recommendations \
  -H "Content-Type: application/json" \
  -d '{
    "skills": ["React", "Node.js", "TypeScript"],
    "cgpa": 8.5,
    "interests": ["Web", "Full Stack Development"],
    "preferred_location": "Remote",
    "preferred_type": "Remote",
    "top_n": 10
  }'
```

#### Example 2: Data Scientist
```bash
curl -X POST http://localhost:8000/api/v1/recommendations \
  -H "Content-Type: application/json" \
  -d '{
    "skills": ["Python", "SQL", "scikit-learn", "TensorFlow"],
    "cgpa": 9.0,
    "interests": ["Data Science", "Machine Learning"],
    "preferred_location": "Bangalore, India",
    "preferred_type": "Hybrid",
    "top_n": 5
  }'
```

#### Example 3: New User (No Profile)
```bash
curl -X POST http://localhost:8000/api/v1/recommendations \
  -H "Content-Type: application/json" \
  -d '{
    "skills": [],
    "cgpa": 0.0,
    "interests": [],
    "preferred_location": "",
    "preferred_type": "Any",
    "top_n": 5
  }'
# Returns 5 random internships with 60-80% match scores
```

### Match Score Calculation
```
base_score = domain_probability × 100

Bonuses:
  + 5% if preferred_location matches internship location
  + 5% if preferred_type matches internship type

Final Score = min(100, base_score + bonuses)
```

### Scoring Examples
- **Profile match**: Base 50% (domain) + 5% (location) + 5% (type) = **60%**
- **Strong profile match**: Base 80% (domain) + 5% (location) + 5% (type) = **90%**
- **Perfect match**: Base 95% (domain) + 5% (location) + 0% (flexible type) = **100%**
- **Empty profile**: Random **60-80%** scores

---

## Implementation Notes

### Backend
- Uses Random Forest ML model when available
- Falls back to heuristic scoring if model not loaded
- Empty profiles get uniform domain distribution
- Supports async/await for non-blocking requests

### Frontend (Flutter)
```dart
// Flutter example usage
final recommendations = await apiService.getRecommendations(
  skills: ['Python', 'React'],
  cgpa: 8.5,
  interests: ['Web'],
  preferredLocation: 'Remote',
  preferredType: 'Remote',
);
```

### Frontend (React - Admin)
```typescript
// React example usage
const response = await fetch('/api/v1/recommendations', {
  method: 'POST',
  body: JSON.stringify({
    skills: ['Python'],
    cgpa: 8.0,
    interests: ['AI/ML'],
    preferred_location: 'Remote',
    preferred_type: 'Remote',
    top_n: 10,
  }),
});
```

---

## Performance Notes
- Database fetches **all internships** for scoring (not limited)
- Sorting is in-memory after scoring
- Supports top_n up to 30 recommendations
- Typical response time: 100-500ms depending on database size
- Recommended to cache results for 5-10 minutes per user

## Error Handling
Always handle these potential errors:
1. **Empty internship database** → Returns empty array
2. **Invalid CGPA** → Normalizes to 0.0-10.0 range
3. **Invalid skills/interests** → Filters out unknown values
4. **Unknown domains** → Assigns 0 probability

---

**Last Updated**: April 28, 2026
**Status**: ✅ Production Ready
