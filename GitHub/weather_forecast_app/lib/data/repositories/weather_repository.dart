import '../models/forecast_model.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  WeatherRepository(this._apiService);

  final WeatherApiService _apiService;

  Future<WeatherModel> getCurrentWeather(String city) {
    return _apiService.getCurrentWeather(city.trim());
  }

  Future<ForecastModel> getForecast(String city) {
    return _apiService.getForecast(city.trim());
  }

  Future<({WeatherModel current, ForecastModel forecast})> getWeatherBundle(
    String city,
  ) async {
    final results = await Future.wait([
      getCurrentWeather(city),
      getForecast(city),
    ]);
    return (
      current: results[0] as WeatherModel,
      forecast: results[1] as ForecastModel,
    );
  }
}
