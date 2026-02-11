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

**Important (Web):** Changes to `pubspec.yaml` assets or translation files require a full restart (`flutter clean && flutter run -d chrome`), not hot reload. Debug mode on web is significantly slower than release — use `flutter run -d chrome --release` for accurate performance testing.

## Architecture

This is **Animal Quiz Academy**, a Flutter educational quiz app about animals with gamified progression (coins, per-level progress tracking).

### State Management

Uses a single `GameState` ChangeNotifier (`lib/models/game_state.dart`) — no Provider package. Screens call `addListener()` directly in `initState()` and remove in `dispose()`, then `setState(() {})` to sync UI.

### Navigation

Stack-based with manual `Navigator.push()` / `pushAndRemoveUntil()`. No router package. Custom `PageRouteBuilder` for fade transitions.

**Flow:** SplashScreen → LoginScreen → HomeScreen → LevelDetailScreen → QuizScreen (results overlay)

### Key Directories

- `lib/screens/` — 5 screen widgets (splash, login, home, level_detail, quiz)
- `lib/widgets/` — Reusable components (animal_thumbnail, answer_button, coin_badge, home_header, level_card, level_grid, profile_view, quiz_feedback, quiz_input_section, quiz_results)
- `lib/models/` — Data classes: `Animal`, `Level`, `GameState`
- `lib/data/quiz_data.dart` — Static quiz content: 6 levels × 20 animals each
- `lib/theme/app_theme.dart` — Centralized color palette, typography (Nunito via google_fonts), Material 3 theme
- `translations/` — Localization JSON files (en.json, it.json)

### Localization (i18n)

Uses `easy_localization` with Italian (default) and English.

- **Translation files:** `translations/en.json` and `translations/it.json` (~160 keys each: UI strings, 6 level titles, 120 animal names)
- **Translation path:** `path: 'translations'` (NOT `assets/translations` — Flutter Web doubles the `assets/` prefix)
- **Locale persistence:** Disabled (`saveLocale: false`) to avoid `SharedPreferences` `MissingPluginException` on web. App always starts in Italian.
- **Null-safe context access:** `EasyLocalization.of(context)` is accessed with `?.` in `AnimalQuizApp.build()` to handle the case where the provider hasn't initialized yet (avoids `Unexpected null value` crash on web's first frame)
- **Animal name keys:** `Animal.translationKey` getter produces `'animal_lion'`, `'animal_komodo_dragon'`, etc. Quiz answer comparison uses `animal.translationKey.tr().toLowerCase()`
- **Level title keys:** `Level.titleKey` getter produces `'level_1'`, `'level_2'`, etc.
- **Language switcher:** `ProfileView` widget (Profile tab) with `SegmentedButton` for IT/EN, uses `context.setLocale()`

### Data & Persistence

All data is in-memory only — no local storage or backend. Quiz content is hardcoded in `quiz_data.dart`. Login is mocked (no real auth). Language preference is not persisted.

## Dependencies

- `easy_localization` — Multi-language support (EN/IT)
- `google_fonts` — Nunito font family
- `cupertino_icons` — iOS-style icons
- Linting via `flutter_lints`

## Conventions

- Stateful widgets for interactive screens, stateless for simple display components
- Press animations use `AnimatedScale` (0.93–0.96 scale factors)
- Purple gradient theme with gold accent for coins; per-level accent colors defined in `AppTheme`
- Coin reward: +10 per correct quiz answer
- All 6 levels are unlocked from start; progress tracked per-animal as `Map<int, List<bool>>`
- All user-facing strings use `.tr()` from easy_localization — no hardcoded display text in widgets
