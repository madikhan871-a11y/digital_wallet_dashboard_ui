import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherModel> getCurrentWeather(String city) async {
    final response = await _get(ApiConstants.currentWeatherByCity(city));
    return WeatherModel.fromJson(response);
  }

  Future<ForecastModel> getForecast(String city) async {
    final response = await _get(ApiConstants.forecastByCity(city));
    return ForecastModel.fromJson(response);
  }

  Future<Map<String, dynamic>> _get(String url) async {
    if (ApiConstants.apiKey == 'YOUR_OPENWEATHERMAP_API_KEY' ||
        ApiConstants.apiKey.isEmpty) {
      throw const UnauthorizedException();
    }

    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(AppConstants.apiTimeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      switch (response.statusCode) {
        case 200:
          return body;
        case 401:
          throw const UnauthorizedException();
        case 404:
          throw const NotFoundException();
        case 429:
          throw const ServerException(
            'API rate limit exceeded. Please try again later.',
          );
        default:
          final message = body['message'] as String?;
          throw ServerException(
            message != null && message.isNotEmpty
                ? WeatherApiService._capitalize(message)
                : 'Failed to fetch weather data (${response.statusCode}).',
          );
      }
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    } on SocketException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } on FormatException {
      throw const ServerException('Invalid response from weather service.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void dispose() => _client.close();
}
