# Backend Requirements — Hints, Coin Spending & Fuzzy Matching

## 1. New Endpoint: Buy Hint

### `POST /quiz/buy-hint`

Buys the next hint for a specific animal. Backend determines the cost based on how many hints the user already has (prevents client-side tampering).

**Request:**
```json
{
  "levelId": 1,
  "animalIndex": 3
}
```

**Success (200):**
```json
{
  "totalCoins": 85,
  "hintsRevealed": 2
}
```

**Errors:**

| Status | Code | When |
|--------|------|------|
| 400 | `insufficient_coins` | Balance < cost |
| 400 | `max_hints_reached` | Already revealed all 3 hints |

**Hint cost schedule (server-side):**

| Hint # | Cost |
|--------|------|
| 1st | 5 |
| 2nd | 10 |
| 3rd | 20 |

**Firestore transaction:**
1. Read `users/{uid}` — get `totalCoins`
2. Read `progress/{uid}/levels/{levelId}/animals/{animalIndex}` — get `hintsRevealed`
3. Validate: `hintsRevealed < 3` and `totalCoins >= cost`
4. Write: decrement `totalCoins`, increment `hintsRevealed`
5. Write: update `leaderboard/{uid}.totalCoins`

All writes must be atomic (single transaction).

---

## 2. Updated Endpoint: User Progress

### `GET /users/me/progress`

Now returns `hintsRevealed` per animal alongside the existing `guessed` boolean.

**Response:**
```json
{
  "levels": {
    "1": [
      { "guessed": true, "hintsRevealed": 0 },
      { "guessed": false, "hintsRevealed": 2 },
      { "guessed": false, "hintsRevealed": 0 }
    ],
    "2": [
      { "guessed": false, "hintsRevealed": 1 }
    ]
  }
}
```

The client already handles both formats (plain `bool` and `{ guessed, hintsRevealed }` objects), so this can be rolled out without breaking older clients.

---

## 3. Updated Endpoint: Submit Answer (Fuzzy Matching)

### `POST /quiz/answer`

Add Levenshtein-based fuzzy matching so close guesses are accepted.

**Algorithm:**
- Comparison is case-insensitive
- Compute Levenshtein edit distance between guess and correct answer
- Accept if distance <= threshold:
  - Words with 1–7 characters: allow **1** edit
  - Words with 8+ characters: allow **2** edits

**Response change:** always return `correctAnswer` (the properly spelled name), even on correct guesses. The client displays it to show the user the right spelling.

```json
{
  "correct": true,
  "coinsAwarded": 10,
  "totalCoins": 95,
  "correctAnswer": "Elephant"
}
```

---

## No Changes Needed

| Endpoint | Reason |
|----------|--------|
| `GET /users/me/coins` | Already reads `totalCoins` — reflects deductions automatically |
| `GET /leaderboard` | Already reads from leaderboard collection — reflects updated rankings |
| `GET /levels` | No changes |

---

## Removed

`POST /users/me/spend-coins` — replaced entirely by `POST /quiz/buy-hint`.
