# Animal Quiz Academy

A Flutter quiz app that tests your knowledge of animals across six categories: safari animals, ocean creatures, tropical birds, reptiles and amphibians, forest animals, and insects. Each category has twenty animals presented as free-text input questions, with coin rewards for correct answers and per-level progress tracking. Supports English and Italian with an in-app language switcher.

## Requirements

- Flutter SDK (Dart ^3.10.8)

## Setup

```
flutter pub get
```

## Running

```
flutter run
```

To target a specific platform:

```
flutter run -d chrome
flutter run -d macos
flutter run -d ios
flutter run -d android
```

## Environment Configuration

Runtime configuration is passed via `--dart-define` flags. No `.env` file is used.

| Variable | Description | Default |
|----------|-------------|---------|
| `USE_MOCK` | Use mock repositories (no backend needed) | `""` (false) |
| `API_URL` | Backend API base URL | `""` |
| `ENV` | Environment name (`dev`, `prod`) | `dev` |

### Mock mode (default for local development)

Runs entirely offline with hardcoded quiz data and mock auth:

```
flutter run -d chrome --dart-define=USE_MOCK=true
```

### API mode (with backend)

Connects to a real backend server:

```
flutter run -d chrome --dart-define=API_URL=https://api.example.com/api/v1
```

You can combine multiple flags:

```
flutter run -d chrome --dart-define=API_URL=http://localhost:8080/api/v1 --dart-define=ENV=dev
```

## Testing

```
flutter test
```

## Building

```
flutter build apk
flutter build ios
flutter build web
flutter build macos
```

## Project Structure

- `lib/screens/` -- App screens (splash, login, home, level detail, quiz)
- `lib/widgets/` -- Reusable UI components (answer buttons, animal cards, coin badge, level cards, profile view)
- `lib/models/` -- Data classes for animals, levels, and game state
- `lib/data/` -- Hardcoded quiz content (6 levels, 120 animals total)
- `lib/theme/` -- Colors, typography, and Material 3 theme configuration
- `translations/` -- Localization files (en.json, it.json)

## Localization

The app supports English and Italian via `easy_localization`. Italian is the default language. Switch languages from the Profile tab using the IT/EN toggle. All UI text, level titles, and animal names are translated.
