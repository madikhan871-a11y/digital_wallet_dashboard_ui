# SkyCast — Weather Forecast App

Modern Flutter weather app with Material 3 UI, Provider state management, and OpenWeatherMap integration.

## Features

- Splash screen with animated branding
- Local login & signup (SharedPreferences)
- Current weather with temperature, humidity, wind, pressure, sunrise & sunset
- City search with popular suggestions
- Up to 7-day forecast (aggregated from OpenWeatherMap 5-day / 3-hour data)
- Favorite cities (persist locally)
- Light & dark themes
- Responsive layouts for phone and tablet
- Loading indicators & structured error handling
- Clean architecture + null safety

## Setup

1. **Get an API key** from [OpenWeatherMap](https://home.openweathermap.org/api_keys) (free tier is enough).

2. **Set the key** (pick one):

   **Option A — dart-define (recommended)**
   ```bash
   flutter run --dart-define=OWM_API_KEY=your_api_key_here
   ```

   **Option B — edit constants**
   Open `lib/core/constants/api_constants.dart` and replace:
   ```dart
   defaultValue: 'YOUR_OPENWEATHERMAP_API_KEY',
   ```
   with your key.

3. **Install & run**
   ```bash
   flutter pub get
   flutter run
   ```

> New OpenWeatherMap keys can take up to ~10–30 minutes to activate.

## Project structure

```
lib/
├── main.dart
├── core/
│   ├── constants/      # API & app constants
│   ├── theme/          # Material 3 light/dark themes
│   ├── utils/          # Date & weather helpers
│   └── errors/         # Typed exceptions
├── data/
│   ├── models/         # Weather, forecast, user
│   ├── services/       # REST + local storage
│   └── repositories/   # Clean data access
├── providers/          # Provider ChangeNotifiers
└── presentation/
    ├── screens/        # Splash, auth, home, search, forecast, favorites
    └── widgets/        # Reusable UI pieces
```

## Auth notes

Accounts are stored **only on device**. This is intentional for the local-auth requirement — not for production cloud auth.

## Packages

| Package | Role |
|---------|------|
| `provider` | State management |
| `http` | OpenWeatherMap REST calls |
| `shared_preferences` | Theme, auth, favorites |
| `google_fonts` | Outfit typography |
| `flutter_spinkit` | Loading animation |
| `cached_network_image` | Weather icons |
| `intl` | Date/time formatting |
