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

## Architecture

This is **Animal Quiz Academy**, a Flutter educational quiz app about animals with gamified progression (coins, per-level progress tracking).

### State Management

Uses a single `GameState` ChangeNotifier (`lib/models/game_state.dart`) — no Provider package. Screens call `addListener()` directly in `initState()` and remove in `dispose()`, then `setState(() {})` to sync UI.

### Navigation

Stack-based with manual `Navigator.push()` / `pushAndRemoveUntil()`. No router package. Custom `PageRouteBuilder` for fade transitions.

**Flow:** SplashScreen → LoginScreen → HomeScreen → LevelDetailScreen → QuizScreen (results overlay)

### Key Directories

- `lib/screens/` — 5 screen widgets (splash, login, home, level_detail, quiz)
- `lib/widgets/` — Reusable components (animal_thumbnail, answer_button, coin_badge, level_card)
- `lib/models/` — Data classes: `Animal`, `Level`, `GameState`
- `lib/data/quiz_data.dart` — Static quiz content: 6 levels × 10 animals each
- `lib/theme/app_theme.dart` — Centralized color palette, typography (Nunito via google_fonts), Material 3 theme

### Data & Persistence

All data is in-memory only — no local storage or backend. Quiz content is hardcoded in `quiz_data.dart`. Login is mocked (no real auth).

## Dependencies

Minimal: only `google_fonts` and `cupertino_icons` beyond Flutter SDK. Linting via `flutter_lints`.

## Conventions

- Stateful widgets for interactive screens, stateless for simple display components
- Press animations use `AnimatedScale` (0.93–0.96 scale factors)
- Purple gradient theme with gold accent for coins; per-level accent colors defined in `AppTheme`
- Coin reward: +10 per correct quiz answer
- All 6 levels are unlocked from start; progress tracked per-animal as `Map<int, List<bool>>`
