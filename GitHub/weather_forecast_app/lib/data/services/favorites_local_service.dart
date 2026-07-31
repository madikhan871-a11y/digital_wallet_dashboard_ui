import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class FavoritesLocalService {
  FavoritesLocalService(this._prefs);

  final SharedPreferences _prefs;

  List<String> getFavorites() {
    return _prefs.getStringList(AppConstants.keyFavorites) ?? [];
  }

  Future<void> saveFavorites(List<String> cities) async {
    await _prefs.setStringList(AppConstants.keyFavorites, cities);
  }

  Future<void> addFavorite(String city) async {
    final favorites = getFavorites();
    final normalized = city.trim();
    if (normalized.isEmpty) return;
    final exists = favorites.any(
      (c) => c.toLowerCase() == normalized.toLowerCase(),
    );
    if (!exists) {
      favorites.add(normalized);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String city) async {
    final favorites = getFavorites();
    favorites.removeWhere(
      (c) => c.toLowerCase() == city.trim().toLowerCase(),
    );
    await saveFavorites(favorites);
  }

  bool isFavorite(String city) {
    return getFavorites().any(
      (c) => c.toLowerCase() == city.trim().toLowerCase(),
    );
  }

  Future<void> setLastCity(String city) async {
    await _prefs.setString(AppConstants.keyLastCity, city.trim());
  }

  String? getLastCity() => _prefs.getString(AppConstants.keyLastCity);
}
