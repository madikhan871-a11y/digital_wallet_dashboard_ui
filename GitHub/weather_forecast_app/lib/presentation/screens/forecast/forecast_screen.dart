import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/weather_utils.dart';
import '../../../data/models/forecast_model.dart';
import '../../../providers/weather_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/forecast_day_tile.dart';
import '../../widgets/loading_indicator.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final days = weather.dailyForecast;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 900 ? width * 0.12 : (width > 600 ? 32.0 : 16.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          weather.hasData
              ? '7-day · ${weather.activeCity}'
              : '7-day forecast',
        ),
      ),
      body: Builder(
        builder: (context) {
          if (weather.isLoading && days.isEmpty) {
            return const LoadingIndicator(message: 'Loading forecast…');
          }

          if (weather.status == WeatherStatus.error && days.isEmpty) {
            return ErrorView(
              message: weather.error ?? 'Unable to load forecast',
              onRetry: () => context.read<WeatherProvider>().refresh(),
            );
          }

          if (days.isEmpty) {
            return const ErrorView(message: 'No forecast data available.');
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 32),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final day = days[index];
              return Column(
                children: [
                  ForecastDayTile(
                    day: day,
                    onTap: () => _showDayDetails(context, day),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showDayDetails(BuildContext context, DailyForecast day) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTimeHelper.formatWeekday(day.date),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                WeatherUtils.capitalize(day.description),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _chip(
                    context,
                    Icons.thermostat_rounded,
                    'High / Low',
                    '${day.tempMax.round()}° / ${day.tempMin.round()}°',
                  ),
                  _chip(
                    context,
                    Icons.water_drop_outlined,
                    'Humidity',
                    WeatherUtils.humidity(day.humidity),
                  ),
                  _chip(
                    context,
                    Icons.air_rounded,
                    'Wind',
                    WeatherUtils.windSpeed(day.windSpeed),
                  ),
                  _chip(
                    context,
                    Icons.speed_rounded,
                    'Pressure',
                    WeatherUtils.pressure(day.pressure),
                  ),
                  _chip(
                    context,
                    Icons.umbrella_rounded,
                    'Rain chance',
                    '${(day.pop * 100).round()}%',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Hourly',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: day.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = day.items[index];
                    return Container(
                      width: 84,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateTimeHelper.formatTime(item.dateTime),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            WeatherUtils.iconForCondition(item.mainCondition),
                            size: 22,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            WeatherUtils.temperature(item.temperature),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
