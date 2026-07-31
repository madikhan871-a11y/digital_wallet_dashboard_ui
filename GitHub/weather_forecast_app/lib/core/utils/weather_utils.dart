import 'package:flutter/material.dart';

class WeatherUtils {
  WeatherUtils._();

  static String temperature(double temp) => '${temp.round()}°';

  static String humidity(int value) => '$value%';

  static String windSpeed(double speed) => '${speed.toStringAsFixed(1)} m/s';

  static String pressure(int value) => '$value hPa';

  static IconData iconForCondition(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return Icons.blur_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
