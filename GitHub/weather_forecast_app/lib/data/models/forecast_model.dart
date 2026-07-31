class ForecastItem {
  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.iconCode,
    required this.pop,
  });

  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final String iconCode;
  final double pop; // probability of precipitation 0-1

  factory ForecastItem.fromJson(
    Map<String, dynamic> json, {
    int timezoneOffset = 0,
  }) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final dt = (json['dt'] as num).toInt();

    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (dt + timezoneOffset) * 1000,
        isUtc: true,
      ),
      temperature: (main['temp'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      pressure: (main['pressure'] as num).toInt(),
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      description: weather['description'] as String? ?? '',
      mainCondition: weather['main'] as String? ?? '',
      iconCode: weather['icon'] as String? ?? '01d',
      pop: (json['pop'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.iconCode,
    required this.pop,
    required this.items,
  });

  final DateTime date;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final String iconCode;
  final double pop;
  final List<ForecastItem> items;
}

class ForecastModel {
  const ForecastModel({
    required this.cityName,
    required this.country,
    required this.timezoneOffset,
    required this.items,
    required this.daily,
  });

  final String cityName;
  final String country;
  final int timezoneOffset;
  final List<ForecastItem> items;
  final List<DailyForecast> daily;

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>? ?? {};
    final timezone = (city['timezone'] as num?)?.toInt() ?? 0;
    final list = (json['list'] as List).cast<Map<String, dynamic>>();

    final items = list
        .map((e) => ForecastItem.fromJson(e, timezoneOffset: timezone))
        .toList();

    return ForecastModel(
      cityName: city['name'] as String? ?? '',
      country: city['country'] as String? ?? '',
      timezoneOffset: timezone,
      items: items,
      daily: _aggregateDaily(items),
    );
  }

  /// Groups 3-hour slots into daily forecasts (up to 7 days).
  static List<DailyForecast> _aggregateDaily(List<ForecastItem> items) {
    final Map<String, List<ForecastItem>> grouped = {};

    for (final item in items) {
      final key =
          '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final days = <DailyForecast>[];
    for (final entry in grouped.entries) {
      final dayItems = entry.value;
      dayItems.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      // Prefer midday icon/description when available
      final midday = dayItems.firstWhere(
        (i) => i.dateTime.hour >= 11 && i.dateTime.hour <= 14,
        orElse: () => dayItems[dayItems.length ~/ 2],
      );

      days.add(
        DailyForecast(
          date: DateTime(
            dayItems.first.dateTime.year,
            dayItems.first.dateTime.month,
            dayItems.first.dateTime.day,
          ),
          tempMin: dayItems.map((e) => e.tempMin).reduce((a, b) => a < b ? a : b),
          tempMax: dayItems.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b),
          humidity: (dayItems.map((e) => e.humidity).reduce((a, b) => a + b) /
                  dayItems.length)
              .round(),
          pressure: (dayItems.map((e) => e.pressure).reduce((a, b) => a + b) /
                  dayItems.length)
              .round(),
          windSpeed:
              dayItems.map((e) => e.windSpeed).reduce((a, b) => a + b) /
                  dayItems.length,
          description: midday.description,
          mainCondition: midday.mainCondition,
          iconCode: midday.iconCode,
          pop: dayItems.map((e) => e.pop).reduce((a, b) => a > b ? a : b),
          items: dayItems,
        ),
      );
    }

    days.sort((a, b) => a.date.compareTo(b.date));
    return days.take(7).toList();
  }
}
