import 'package:flutter/foundation.dart';

import '../data/repositories/favorites_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._repository) {
    _favorites = List.unmodifiable(_repository.getFavorites());
  }

  final FavoritesRepository _repository;

  List<String> _favorites = const [];

  List<String> get favorites => _favorites;

  bool isFavorite(String city) => _repository.isFavorite(city);

  Future<void> toggleFavorite(String city) async {
    if (isFavorite(city)) {
      await _repository.removeFavorite(city);
    } else {
      await _repository.addFavorite(city);
    }
    _refresh();
  }

  Future<void> addFavorite(String city) async {
    await _repository.addFavorite(city);
    _refresh();
  }

  Future<void> removeFavorite(String city) async {
    await _repository.removeFavorite(city);
    _refresh();
  }

  Future<void> setLastCity(String city) => _repository.setLastCity(city);

  String? getLastCity() => _repository.getLastCity();

  void _refresh() {
    _favorites = List.unmodifiable(_repository.getFavorites());
    notifyListeners();
  }
}
