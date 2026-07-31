import 'package:flutter_test/flutter_test.dart';

import 'package:weather_forecast_app/data/models/forecast_model.dart';
import 'package:weather_forecast_app/data/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    test('parses current weather json', () {
      final model = WeatherModel.fromJson({
        'name': 'London',
        'timezone': 0,
        'dt': 1700000000,
        'coord': {'lat': 51.5, 'lon': -0.12},
        'weather': [
          {
            'main': 'Clouds',
            'description': 'scattered clouds',
            'icon': '03d',
          }
        ],
        'main': {
          'temp': 12.5,
          'feels_like': 11.0,
          'temp_min': 10.0,
          'temp_max': 14.0,
          'pressure': 1012,
          'humidity': 70,
        },
        'wind': {'speed': 3.5},
        'sys': {
          'country': 'GB',
          'sunrise': 1699950000,
          'sunset': 1699986000,
        },
      });

      expect(model.cityName, 'London');
      expect(model.country, 'GB');
      expect(model.temperature, 12.5);
      expect(model.humidity, 70);
      expect(model.locationLabel, 'London, GB');
    });
  });

  group('ForecastModel', () {
    test('aggregates daily forecasts', () {
      final model = ForecastModel.fromJson({
        'city': {'name': 'London', 'country': 'GB', 'timezone': 0},
        'list': [
          for (var i = 0; i < 8; i++)
            {
              'dt': 1700000000 + i * 10800,
              'main': {
                'temp': 10.0 + i,
                'temp_min': 9.0,
                'temp_max': 12.0 + i,
                'pressure': 1010,
                'humidity': 60,
              },
              'weather': [
                {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
              ],
              'wind': {'speed': 2.0},
              'pop': 0.1,
            },
        ],
      });

      expect(model.cityName, 'London');
      expect(model.items.length, 8);
      expect(model.daily.isNotEmpty, isTrue);
      expect(model.daily.length, lessThanOrEqualTo(7));
    });
  });
}
