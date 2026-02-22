# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Run the app (debug mode)
flutter run

# Run on a specific platform
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d ios            # iOS simulator
flutter run -d android        # Android emulator

# Run with environment config
flutter run --dart-define=USE_MOCK=true          # Mock mode (no backend)
flutter run --dart-define=API_URL=https://...     # Real backend
flutter run --dart-define=ENV=prod                # Production env

# Build release
flutter build apk            # Android
flutter build ios             # iOS
flutter build web             # Web
flutter build macos           # macOS

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code (lint)
flutter analyze

# Get dependencies
flutter pub get
```

**Important (Web):** Changes to `pubspec.yaml` assets or translation files require a full restart (`flutter clean && flutter run -d chrome`), not hot reload. Debug mode on web is significantly slower than release — use `flutter run -d chrome --release` for accurate performance testing.

## Architecture

This is **Animal Quiz Academy**, a Flutter educational quiz app about animals with gamified progression (coins, hints, per-level progress tracking, leaderboard).

### State Management

Uses a single `GameState` ChangeNotifier (`lib/models/game_state.dart`) — no Provider package. Screens call `addListener()` directly in `initState()` and remove in `dispose()`, then `setState(() {})` to sync UI.

**GameState tracks:** username, totalCoins, levels list, levelProgress (`Map<int, List<bool>>`), hintsProgress (`Map<int, List<int>>`), isLoading, error.

### Navigation

Stack-based with manual `Navigator.push()` / `pushAndRemoveUntil()`. No router package. Custom `PageRouteBuilder` for fade transitions (400ms).

**Flow:** SplashScreen (session check) → LoginScreen → HomeScreen (3-tab BottomNav: Home, Leaderboard, Profile) → LevelDetailScreen → QuizScreen (results overlay)

### Repository Pattern & Service Locator

All data access goes through abstract repository interfaces. `ServiceLocator` singleton selects implementation at runtime based on `Env.isMock`:

- **Mock mode** (`--dart-define=USE_MOCK=true`): In-memory repositories with hardcoded data
- **Real mode**: Firebase Auth + HTTP API repositories

```
lib/repositories/
├── auth_repository.dart          # Abstract: signInWithGoogle, signInAnonymously, signOut, registerProfile, getCurrentUser, getIdToken
├── quiz_repository.dart          # Abstract: getLevels, getLevel, submitAnswer, getProgress, getCoins, buyHint
├── leaderboard_repository.dart   # Abstract: getLeaderboard
├── firebase/
│   ├── firebase_auth_repository.dart     # Firebase Auth + API profile registration
│   ├── google_sign_in_native.dart        # Native Google Sign-In (iOS/Android)
│   └── google_sign_in_stub.dart          # Web stub (uses signInWithPopup)
├── api/
│   ├── api_quiz_repository.dart          # HTTP API for quiz operations
│   └── api_leaderboard_repository.dart   # HTTP API for leaderboard
└── mock/
    ├── mock_auth_repository.dart
    ├── mock_quiz_repository.dart
    └── mock_leaderboard_repository.dart
```

### API Client (`lib/services/api_client.dart`)

HTTP wrapper with Firebase ID token injection. Methods: `get()`, `getOrNull()`, `post()`, `patch()`. Adds headers: `Content-Type`, `Accept`, `Accept-Language` (current locale), `Authorization: Bearer {idToken}`.

**API endpoints:** `GET /levels`, `GET /levels/{id}`, `POST /quiz/answer`, `GET /users/me/progress`, `GET /users/me/coins`, `POST /quiz/buy-hint`, `POST /auth/register`, `GET /auth/me`, `GET /leaderboard?limit=50&offset=0`

### Authentication

- **Google Sign-In:** Web uses `signInWithPopup(GoogleAuthProvider)`, mobile uses `google_sign_in` package → `GoogleAuthProvider.credential()`
- **Guest login:** `signInAnonymously()` + register profile with username on backend
- **Session restoration:** SplashScreen checks for existing Firebase token, restores GameState if found
- **iOS config:** `GoogleService-Info.plist` in `ios/Runner/`, `REVERSED_CLIENT_ID` URL scheme in `Info.plist`

### Key Directories

```
lib/
├── config/env.dart               # Environment config (isMock, apiUrl, isDev, isProd)
├── data/quiz_data.dart           # Static quiz content: 6 levels × 20 animals (used by mock repo)
├── firebase_options.dart         # Platform-specific Firebase credentials
├── main.dart                     # App init: Firebase, EasyLocalization, ServiceLocator
├── models/                       # Data classes (see Models section)
├── repositories/                 # Abstract + concrete data access (see above)
├── screens/                      # 5 screen widgets
├── services/                     # ApiClient + ServiceLocator
├── theme/app_theme.dart          # Colors, gradients, Material 3 theme, Nunito font
├── utils/string_similarity.dart  # Levenshtein distance for fuzzy answer matching
└── widgets/                      # 13 reusable components
translations/
├── en.json                       # English (~40 keys)
└── it.json                       # Italian (~40 keys)
```

### Models (`lib/models/`)

| Model | Key Fields |
|-------|------------|
| `Animal` | id?, name, emoji?, imageUrl?, hints[], funFacts[] |
| `Level` | id, title, emoji?, animals[] |
| `User` | id, username, email, totalCoins, createdAt |
| `GameState` | ChangeNotifier — username, totalCoins, levelProgress, hintsProgress, levels[] |
| `AnswerResult` | correct, coinsAwarded, totalCoins, correctAnswer? |
| `BuyHintResult` | totalCoins, hintsRevealed |
| `LeaderboardEntry` | rank, userId, username, totalCoins, levelsCompleted |

### Screens (`lib/screens/`)

| Screen | Purpose |
|--------|---------|
| `splash_screen.dart` | App entry; checks Firebase session, restores or redirects to login |
| `login_screen.dart` | Google Sign-In + guest login with username field |
| `home_screen.dart` | 3-tab BottomNavigationBar: Home (LevelGrid), Leaderboard, Profile |
| `level_detail_screen.dart` | 3×3 grid of animals per level; tapping opens quiz |
| `quiz_screen.dart` | Quiz game loop: input → submit → feedback → next animal → results |

### Widgets (`lib/widgets/`)

| Widget | Purpose |
|--------|---------|
| `home_header.dart` | "Hello {user}!" greeting + coin badge |
| `level_grid.dart` | GridView of 6 LevelCards |
| `level_card.dart` | Level card with emoji, title, progress bar, locked overlay |
| `animal_thumbnail.dart` | Grid item showing image/emoji + guessed checkmark |
| `animal_emoji_card.dart` | Large emoji/image display in quiz (cached with shimmer) |
| `coin_badge.dart` | Compact coin count (reused in header, appBar, profile) |
| `quiz_input_section.dart` | Character-by-character blank slots; typed letters replace underscores one-by-one; shake animation on wrong answer; invisible TextField overlay for keyboard capture |
| `quiz_hint_section.dart` | Revealed hint boxes + "Buy Hint" button with cost |
| `quiz_feedback.dart` | Wrong/correct message + fun fact card + "Next" button |
| `quiz_results.dart` | Session score recap with coins earned |
| `shimmer_loading.dart` | Animated loading skeleton |
| `leaderboard_view.dart` | Top 50 players list |
| `profile_view.dart` | Avatar, username, coins, language switcher (IT/EN), logout |

### Quiz Input Flow

1. `QuizInputSection` displays character blanks from `animalName` — each letter as `_`, words separated by gaps
2. Invisible `TextField` overlay captures keyboard input (spaces blocked, maxLength = letter count excluding spaces)
3. As user types, underscores are replaced one-by-one with typed letters (purple). Deleting restores underscores.
4. **Auto-submit** triggers when typed letter count matches animal name letter count
5. For multi-word names, spaces are reconstructed automatically before submission (`_insertSpaces()`)
6. **Wrong answer:** text turns red + horizontal shake animation (damped sine, 500ms), then clears after 800ms
7. **Correct answer:** animated transition to revealed name (green, scale+fade), optional fun fact shown
8. **Fuzzy matching** via Levenshtein distance: allows 1 typo for ≤7 chars, 2 for ≥8 chars

### Hints System

- 3 hints per animal, costing [5, 10, 20] coins progressively
- `GameState.buyHint()` → repository → deduct coins, increment `hintsProgress[levelId][animalIndex]`
- `QuizHintSection` shows revealed hints + buy button (disabled if insufficient coins)

### Localization (i18n)

Uses `easy_localization` with Italian (default) and English.

- **Translation files:** `translations/en.json` and `translations/it.json` (~40 keys each)
- **Translation path:** `path: 'translations'` (NOT `assets/translations` — Flutter Web doubles the `assets/` prefix)
- **Locale persistence:** Disabled (`saveLocale: false`) to avoid `SharedPreferences` `MissingPluginException` on web. App always starts in Italian.
- **Null-safe context access:** `EasyLocalization.of(context)` uses `?.` in `AnimalQuizApp.build()` to handle first-frame null on web
- **Language switcher:** `ProfileView` widget with `SegmentedButton` for IT/EN, uses `context.setLocale()`

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication (Google, anonymous) |
| `google_sign_in` | Native Google Sign-In (iOS/Android) |
| `easy_localization` | Multi-language support (EN/IT) |
| `google_fonts` | Nunito font family |
| `http` | HTTP requests to backend API |
| `cached_network_image` | Image caching with placeholders |
| `cupertino_icons` | iOS-style icons |
| `flutter_lints` | Code linting |

## Conventions

- Stateful widgets for interactive screens, stateless for simple display components
- Press animations use `AnimatedScale` (0.93–0.96 scale factors)
- Purple gradient theme (`#6C3FC5`) with gold accent for coins; per-level accent colors in `AppTheme`
- Material 3 enabled with purple seed color; Nunito font throughout
- Coin reward: +10 per correct quiz answer
- Level unlock: Level N requires Level N-1 ≥ 80% complete (Level 1 always unlocked)
- Progress tracked per-animal as `Map<int, List<bool>>`
- All user-facing strings use `.tr()` from easy_localization — no hardcoded display text
- Network images use `CachedNetworkImage` with emoji fallback on error
- `ShimmerLoading` for loading placeholders
