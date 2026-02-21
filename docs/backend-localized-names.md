# Backend: Localized Animal & Level Names

## Context

The Flutter app currently receives animal and level names in English from the API and attempts client-side translation via local JSON files. This is fragile — the client translations can drift, and answer validation breaks when the backend compares against the English name while the user types in Italian.

We want the backend to be the single source of truth for localized content.

## How the client sends locale

The app will send an `Accept-Language` header on every request:

```
Accept-Language: it
```

Possible values: `it`, `en` (more may be added later).

If the header is missing, default to `it`.

## Affected endpoints

### `GET /levels`

Current response:

```json
{
  "levels": [
    {
      "id": 1,
      "title": "Safari Animals",
      "emoji": "🦁",
      "animals": [
        { "id": 1, "name": "Lion", "emoji": "🦁", "imageUrl": "..." },
        { "id": 2, "name": "Elephant", "emoji": "🐘", "imageUrl": "..." }
      ]
    }
  ]
}
```

Expected response when `Accept-Language: it`:

```json
{
  "levels": [
    {
      "id": 1,
      "title": "Animali del Safari",
      "emoji": "🦁",
      "animals": [
        { "id": 1, "name": "Leone", "emoji": "🦁", "imageUrl": "..." },
        { "id": 2, "name": "Elefante", "emoji": "🐘", "imageUrl": "..." }
      ]
    }
  ]
}
```

The `name` and `title` fields should return the localized string. Everything else stays the same.

### `GET /levels/:id`

Same as above, single level object.

### `POST /quiz/answer`

Request body (unchanged):

```json
{
  "levelId": 1,
  "animalIndex": 0,
  "answer": "Leone"
}
```

The backend should compare `answer` against the localized name matching the request's `Accept-Language`. Comparison should be case-insensitive and trimmed.

Response (unchanged shape):

```json
{
  "correct": true,
  "coinsAwarded": 10,
  "totalCoins": 120,
  "correctAnswer": null
}
```

When `correct` is `false`, `correctAnswer` should return the localized name so the client can display it:

```json
{
  "correct": false,
  "coinsAwarded": 0,
  "totalCoins": 110,
  "correctAnswer": "Leone"
}
```

## What does NOT change

- `GET /users/me/progress` — returns `Map<levelId, List<bool>>`, no names involved
- `GET /users/me/coins` — returns `{ "totalCoins": int }`
- `POST /auth/register` / `GET /auth/me` — user profile, no animal data
- `GET /leaderboard` — usernames, not animal names

## Summary of backend work

1. Store animal names and level titles with locale variants (e.g. a translations table or a JSON column per locale)
2. Read `Accept-Language` header on `/levels`, `/levels/:id`, and `/quiz/answer`
3. Return localized `name` (animals) and `title` (levels) in responses
4. Compare quiz answers against the localized name for the request's locale
5. Return localized `correctAnswer` on wrong answers
