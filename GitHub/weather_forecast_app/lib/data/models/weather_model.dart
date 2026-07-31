class WeatherModel {
  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.iconCode,
    required this.sunrise,
    required this.sunset,
    required this.timezoneOffset,
    required this.dateTime,
    this.latitude,
    this.longitude,
  });

  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final String iconCode;
  final DateTime sunrise;
  final DateTime sunset;
  final int timezoneOffset;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final coord = json['coord'] as Map<String, dynamic>?;
    final timezone = (json['timezone'] as num?)?.toInt() ?? 0;
    final dt = (json['dt'] as num).toInt();

    DateTime fromUnix(int seconds) {
      return DateTime.fromMillisecondsSinceEpoch(
        (seconds + timezone) * 1000,
        isUtc: true,
      );
    }

    return WeatherModel(
      cityName: json['name'] as String? ?? '',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      pressure: (main['pressure'] as num).toInt(),
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      description: weather['description'] as String? ?? '',
      mainCondition: weather['main'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '01d',
      sunrise: fromUnix((sys['sunrise'] as num?)?.toInt() ?? dt),
      sunset: fromUnix((sys['sunset'] as num?)?.toInt() ?? dt),
      timezoneOffset: timezone,
      dateTime: fromUnix(dt),
      latitude: (coord?['lat'] as num?)?.toDouble(),
      longitude: (coord?['lon'] as num?)?.toDouble(),
    );
  }

  String get locationLabel {
    if (country.isEmpty) return cityName;
    return '$cityName, $country';
  }
}
