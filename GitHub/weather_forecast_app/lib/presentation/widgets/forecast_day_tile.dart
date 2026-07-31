import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/weather_utils.dart';
import '../../data/models/forecast_model.dart';

class ForecastDayTile extends StatelessWidget {
  const ForecastDayTile({
    super.key,
    required this.day,
    this.compact = false,
    this.onTap,
  });

  final DailyForecast day;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isToday = DateTimeHelper.isSameDay(day.date, DateTime.now());

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: compact
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isToday ? 'Today' : DateTimeHelper.formatShortWeekday(day.date),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                CachedNetworkImage(
                  imageUrl: ApiConstants.weatherIcon(day.iconCode),
                  width: 42,
                  height: 42,
                  errorWidget: (_, __, ___) => Icon(
                    WeatherUtils.iconForCondition(day.mainCondition),
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${day.tempMax.round()}° / ${day.tempMin.round()}°',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    isToday
                        ? 'Today'
                        : DateTimeHelper.formatWeekday(day.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: ApiConstants.weatherIcon(day.iconCode),
                  width: 48,
                  height: 48,
                  errorWidget: (_, __, ___) => Icon(
                    WeatherUtils.iconForCondition(day.mainCondition),
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    WeatherUtils.capitalize(day.description),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${day.tempMax.round()}°',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${day.tempMin.round()}°',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: content,
    );
  }
}
