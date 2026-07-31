import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../data/models/forecast_model.dart';
import '../data/models/weather_model.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/weather_repository.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({
    required WeatherRepository weatherRepository,
    required FavoritesRepository favoritesRepository,
  })  : _weatherRepository = weatherRepository,
        _favoritesRepository = favoritesRepository;

  final WeatherRepository _weatherRepository;
  final FavoritesRepository _favoritesRepository;

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _current;
  ForecastModel? _forecast;
  String? _error;
  String _activeCity = AppConstants.defaultCity;

  WeatherStatus get status => _status;
  WeatherModel? get current => _current;
  ForecastModel? get forecast => _forecast;
  List<DailyForecast> get dailyForecast => _forecast?.daily ?? const [];
  String? get error => _error;
  String get activeCity => _activeCity;
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasData => _current != null;

  Future<void> initialize() async {
    final last = _favoritesRepository.getLastCity();
    await fetchWeather(last ?? AppConstants.defaultCity);
  }

  Future<void> fetchWeather(String city) async {
    final query = city.trim();
    if (query.isEmpty) {
      _error = 'Please enter a city name.';
      _status = WeatherStatus.error;
      notifyListeners();
      return;
    }

    _status = WeatherStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final bundle = await _weatherRepository.getWeatherBundle(query);
      _current = bundle.current;
      _forecast = bundle.forecast;
      _activeCity = bundle.current.cityName;
      await _favoritesRepository.setLastCity(_activeCity);
      _status = WeatherStatus.success;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      _status = WeatherStatus.error;
      notifyListeners();
    } catch (_) {
      _error = 'Unexpected error while loading weather.';
      _status = WeatherStatus.error;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchWeather(_activeCity);

  void clearError() {
    _error = null;
    if (_current != null) {
      _status = WeatherStatus.success;
    } else {
      _status = WeatherStatus.initial;
    }
    notifyListeners();
  }
}
