/// OpenWeatherMap API configuration.
///
/// Get a free API key at https://openweathermap.org/api
/// Then replace [apiKey] below (or pass via --dart-define=OWM_API_KEY=your_key).
class ApiConstants {
  ApiConstants._();

  static const String apiKey = String.fromEnvironment(
    'OWM_API_KEY',
    defaultValue: 'YOUR_OPENWEATHERMAP_API_KEY',
  );

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';
  static const String units = 'metric';

  static String currentWeatherByCity(String city) =>
      '$baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=$units';

  static String forecastByCity(String city) =>
      '$baseUrl/forecast?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=$units';

  static String weatherIcon(String iconCode, {String size = '2x'}) =>
      '$iconBaseUrl/$iconCode@$size.png';
}
