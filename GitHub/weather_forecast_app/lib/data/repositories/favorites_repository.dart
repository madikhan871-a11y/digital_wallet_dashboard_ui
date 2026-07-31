import '../services/favorites_local_service.dart';

class FavoritesRepository {
  FavoritesRepository(this._service);

  final FavoritesLocalService _service;

  List<String> getFavorites() => _service.getFavorites();

  Future<void> addFavorite(String city) => _service.addFavorite(city);

  Future<void> removeFavorite(String city) => _service.removeFavorite(city);

  bool isFavorite(String city) => _service.isFavorite(city);

  Future<void> setLastCity(String city) => _service.setLastCity(city);

  String? getLastCity() => _service.getLastCity();
}
