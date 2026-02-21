# Backend API Guide

Reference for building the Animal Quiz Academy backend. Covers every API call the Flutter app makes, the exact JSON shapes it expects, authentication flow, and error format.

## Authentication

Auth is **client-side via Firebase**. The server never handles login/signup directly.

### Flow

```
1. User signs in on the app (Google, anonymous, or email/password)
       |
       v
2. Firebase returns an ID token (JWT, ~1h expiry, auto-refreshed by client)
       |
       v
3. App sends token as:  Authorization: Bearer <firebase-id-token>
       |
       v
4. Backend verifies token with Firebase Admin SDK
       |
       v
5. Extract `uid` from token -> use as the user's primary key
```

### Token verification (backend)

```python
# Python example (firebase-admin)
from firebase_admin import auth
decoded = auth.verify_id_token(id_token)
uid = decoded['uid']
email = decoded.get('email', '')
```

### Mock auth mode

When `FIREBASE_CREDENTIALS` is not set, accept any non-empty Bearer token and use its value as the user ID. This lets you develop/test without Firebase.

```
Authorization: Bearer test-user-123
-> uid = "test-user-123"
```

---

## Base URL

The app sends requests to the URL set via `--dart-define=API_URL=<base>`.

All paths below are relative to this base (e.g., `https://api.example.com/api/v1`).

---

## Common headers (every request)

```
Content-Type: application/json
Accept: application/json
Authorization: Bearer <firebase-id-token>
```

---

## Error format (all endpoints)

Every error response must follow this shape:

```json
{
  "error": {
    "code": "machine_readable_code",
    "message": "Human-readable description"
  }
}
```

The app reads `error.code` and `error.message` from non-2xx responses. If the body is not valid JSON, the app crashes — always return JSON.

---

## Endpoints

### 1. `POST /auth/register`

**When called:** After first Firebase sign-in, the app checks if a profile exists (`GET /auth/me`). If it gets 404, it calls this to create the profile.

**Request:**

```json
{
  "username": "Antonio"
}
```

- `username` (string, required): 2-30 characters

**Success response (201):**

```json
{
  "id": "firebase-uid-abc123",
  "username": "Antonio",
  "email": "antonio@gmail.com",
  "totalCoins": 0,
  "createdAt": "2026-02-12T10:30:00.000Z"
}
```

- `id`: Use the Firebase UID from the verified token
- `email`: Extract from the Firebase token (`decoded.email`)
- `totalCoins`: Initialize to `0`
- `createdAt`: ISO 8601 timestamp

**Error responses:**
| Status | Code | When |
|--------|------|------|
| 409 | `profile_exists` | User already registered |
| 401 | `unauthorized` | Missing/invalid token |

---

### 2. `GET /auth/me`

**When called:** After every sign-in, to check if the user has a profile.

**Success response (200):**

```json
{
  "id": "firebase-uid-abc123",
  "username": "Antonio",
  "email": "antonio@gmail.com",
  "totalCoins": 150,
  "createdAt": "2026-02-12T10:30:00.000Z"
}
```

**Error responses:**
| Status | Code | When |
|--------|------|------|
| 404 | `user_not_found` | No profile yet (app will call `POST /auth/register`) |
| 401 | `unauthorized` | Missing/invalid token |

**Important:** The app specifically checks for 404 and treats it as "needs registration" — not as a fatal error.

---

### 3. `GET /levels`

**When called:** On HomeScreen load (every time the user reaches the home screen).

**Success response (200):**

```json
{
  "levels": [
    {
      "id": 1,
      "title": "Safari Animals",
      "emoji": "\ud83e\udd81",
      "animals": [
        {
          "id": 1,
          "name": "Lion",
          "emoji": "\ud83e\udd81",
          "imageUrl": "https://example.com/images/lion.jpg"
        },
        {
          "id": 2,
          "name": "Elephant",
          "emoji": "\ud83d\udc18",
          "imageUrl": "https://example.com/images/elephant.jpg"
        }
      ]
    }
  ]
}
```

Each level has 20 animals. There are 6 levels total (120 animals).

**Fields per animal:**

- `id` (int): Unique animal ID
- `name` (string): English name (used as the answer key for comparison)
- `emoji` (string): Single emoji representing the animal
- `imageUrl` (string): URL to the animal's image (shown during quiz)

---

### 4. `GET /levels/{levelId}`

**When called:** Not currently called by the app (level data comes from `GET /levels`), but defined in the spec for future use.

**Success response (200):**

```json
{
  "id": 1,
  "title": "Safari Animals",
  "emoji": "\ud83e\udd81",
  "animals": [
    {
      "id": 1,
      "name": "Lion",
      "emoji": "\ud83e\udd81",
      "imageUrl": "https://example.com/images/lion.jpg",
      "guessed": true
    },
    {
      "id": 2,
      "name": "Elephant",
      "emoji": "\ud83d\udc18",
      "imageUrl": "https://example.com/images/elephant.jpg",
      "guessed": false
    }
  ]
}
```

Same as `GET /levels` but each animal includes `guessed` (bool) for the current user.

**Error responses:**
| Status | Code | When |
|--------|------|------|
| 404 | `level_not_found` | Invalid levelId |

---

### 5. `POST /quiz/answer`

**When called:** Every time the user submits an answer during a quiz.

**Request:**

```json
{
  "levelId": 1,
  "animalIndex": 3,
  "answer": "zebra"
}
```

- `levelId` (int): Which level the quiz is for
- `animalIndex` (int): Zero-based index of the animal within the level (0-19)
- `answer` (string): The user's guess — backend should compare **case-insensitively**

**Success response (200) — correct answer:**

```json
{
  "correct": true,
  "coinsAwarded": 10,
  "totalCoins": 160
}
```

**Success response (200) — wrong answer:**

```json
{
  "correct": false,
  "coinsAwarded": 0,
  "totalCoins": 150,
  "correctAnswer": "Zebra"
}
```

**Success response (200) — correct but already guessed:**

```json
{
  "correct": true,
  "coinsAwarded": 0,
  "totalCoins": 150
}
```

**Fields:**

- `correct` (bool): Whether the answer matched
- `coinsAwarded` (int): Coins earned this submission (10 if correct + first time, 0 otherwise)
- `totalCoins` (int): User's updated total
- `correctAnswer` (string, nullable): Only returned when `correct` is `false`

**Error responses:**
| Status | Code | When |
|--------|------|------|
| 400 | `invalid_request` | Missing fields, invalid levelId/animalIndex |

---

### 6. `GET /users/me/progress`

**When called:** On HomeScreen load (alongside `GET /levels`) to restore per-animal progress.

**Success response (200):**

```json
{
  "levels": {
    "1": [
      true,
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    "2": [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ]
  }
}
```

- Keys are level IDs as **strings** (`"1"`, not `1`)
- Values are arrays of 20 booleans (one per animal, ordered by index)
- `true` = user has correctly guessed this animal
- Levels with no attempts can be omitted

---

### 7. `GET /users/me/coins`

**When called:** To refresh the coin count (e.g., after quiz completion).

**Success response (200):**

```json
{
  "totalCoins": 150
}
```

---

### 8. `PATCH /users/me/profile`

**When called:** If user changes their username (not yet implemented in UI, but defined in spec).

**Request:**

```json
{
  "username": "NewName"
}
```

**Success response (200):**

```json
{
  "id": "firebase-uid-abc123",
  "username": "NewName",
  "email": "antonio@gmail.com",
  "totalCoins": 150,
  "createdAt": "2026-02-12T10:30:00.000Z"
}
```

---

### 9. `GET /leaderboard?limit=50&offset=0`

**When called:** When user taps the Leaderboard tab.

**Query params:**

- `limit` (int, default 50, max 100): Number of entries
- `offset` (int, default 0): Pagination offset

**Success response (200):**

```json
{
  "entries": [
    {
      "rank": 1,
      "userId": "firebase-uid-xyz",
      "username": "TopPlayer",
      "totalCoins": 1200,
      "levelsCompleted": 6
    },
    {
      "rank": 2,
      "userId": "firebase-uid-abc",
      "username": "Antonio",
      "totalCoins": 150,
      "levelsCompleted": 1
    }
  ],
  "total": 42
}
```

- `total` (int): Total number of ranked users (for pagination)
- `levelsCompleted`: Number of levels where all 20 animals are guessed

---

## Call sequence diagram

```
App startup (non-mock mode)
  |
  +--> Firebase.initializeApp()
  |
  +--> [User taps "Login with Google"]
  |      |
  |      +--> Firebase signInWithPopup() ... gets ID token
  |      |
  |      +--> GET /auth/me           (check if profile exists)
  |      |      |
  |      |      +-- 200: profile found, proceed
  |      |      +-- 404: no profile yet
  |      |             |
  |      |             +--> POST /auth/register  (create profile)
  |      |
  |      +--> Navigate to HomeScreen
  |
  +--> [HomeScreen loads]
  |      |
  |      +--> GET /levels            (all levels + animals)
  |      +--> GET /users/me/progress (per-animal guessed booleans)
  |      +--> GET /users/me/coins    (total coin count)
  |
  +--> [User starts a quiz]
  |      |
  |      +--> POST /quiz/answer      (for each answer submitted)
  |      +--> POST /quiz/answer      (repeated per question)
  |      +--> ...
  |
  +--> [User taps Leaderboard tab]
  |      |
  |      +--> GET /leaderboard?limit=50&offset=0
  |
  +--> [User taps "Login with Google" as Guest]
         |
         +--> Firebase signInAnonymously() ... gets ID token
         |
         +--> GET /auth/me -> 404
         |
         +--> POST /auth/register { "username": "Guest" }
```

---

## Database schema suggestion

```
users
  - id: string (Firebase UID, primary key)
  - username: string
  - email: string
  - total_coins: int (default 0)
  - created_at: timestamp

user_progress
  - user_id: string (FK -> users.id)
  - level_id: int
  - animal_index: int
  - guessed: boolean (default false)
  - PRIMARY KEY (user_id, level_id, animal_index)

levels
  - id: int (primary key, 1-6)
  - title: string
  - emoji: string

animals
  - id: int (primary key)
  - level_id: int (FK -> levels.id)
  - index: int (0-19, position within level)
  - name: string
  - emoji: string
  - image_url: string
```

---

## Quick test with curl

```bash
# Mock mode: use any string as token
TOKEN="test-user-1"

# Register
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username": "TestPlayer"}'

# Get profile
curl http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN"

# Get levels
curl http://localhost:8080/api/v1/levels \
  -H "Authorization: Bearer $TOKEN"

# Submit answer
curl -X POST http://localhost:8080/api/v1/quiz/answer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"levelId": 1, "animalIndex": 0, "answer": "lion"}'

# Get progress
curl http://localhost:8080/api/v1/users/me/progress \
  -H "Authorization: Bearer $TOKEN"

# Get coins
curl http://localhost:8080/api/v1/users/me/coins \
  -H "Authorization: Bearer $TOKEN"

# Get leaderboard
curl "http://localhost:8080/api/v1/leaderboard?limit=10&offset=0" \
  -H "Authorization: Bearer $TOKEN"
```
