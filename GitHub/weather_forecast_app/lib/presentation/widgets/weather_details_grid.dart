import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/weather_utils.dart';
import '../../data/models/weather_model.dart';

class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key, required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: WeatherUtils.humidity(weather.humidity),
      ),
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: WeatherUtils.windSpeed(weather.windSpeed),
      ),
      _DetailItem(
        icon: Icons.speed_rounded,
        label: 'Pressure',
        value: WeatherUtils.pressure(weather.pressure),
      ),
      _DetailItem(
        icon: Icons.wb_twilight_rounded,
        label: 'Sunrise',
        value: DateTimeHelper.formatTime(weather.sunrise),
      ),
      _DetailItem(
        icon: Icons.nights_stay_rounded,
        label: 'Sunset',
        value: DateTimeHelper.formatTime(weather.sunset),
      ),
      _DetailItem(
        icon: Icons.thermostat_rounded,
        label: 'Feels like',
        value: WeatherUtils.temperature(weather.feelsLike),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.45,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _DetailTile(item: item);
          },
        );
      },
    );
  }
}

class _DetailItem {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.item});

  final _DetailItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: scheme.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            item.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
