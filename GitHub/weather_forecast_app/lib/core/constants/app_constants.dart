class AppConstants {
  AppConstants._();

  static const String appName = 'SkyCast';
  static const String defaultCity = 'London';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyUsers = 'local_users';
  static const String keyLoggedInEmail = 'logged_in_email';
  static const String keyFavorites = 'favorite_cities';
  static const String keyLastCity = 'last_city';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 15);
}
