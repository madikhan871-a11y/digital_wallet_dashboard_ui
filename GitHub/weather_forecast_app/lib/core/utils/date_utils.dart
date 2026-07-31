import 'package:intl/intl.dart';

class DateTimeHelper {
  DateTimeHelper._();

  static String formatTime(DateTime dateTime) =>
      DateFormat('h:mm a').format(dateTime);

  static String formatDate(DateTime dateTime) =>
      DateFormat('EEE, MMM d').format(dateTime);

  static String formatWeekday(DateTime dateTime) =>
      DateFormat('EEEE').format(dateTime);

  static String formatShortWeekday(DateTime dateTime) =>
      DateFormat('EEE').format(dateTime);

  static String formatFull(DateTime dateTime) =>
      DateFormat('EEEE, MMMM d • h:mm a').format(dateTime);

  /// Converts UTC unix seconds + timezone offset (seconds) to local DateTime.
  static DateTime fromUnix(int unixSeconds, {int timezoneOffsetSeconds = 0}) {
    return DateTime.fromMillisecondsSinceEpoch(
      (unixSeconds + timezoneOffsetSeconds) * 1000,
      isUtc: true,
    );
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
