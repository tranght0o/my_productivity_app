import 'package:intl/intl.dart';
import '../screens/insight/widgets/time_range_dropdown.dart';

enum GroupUnit { day, month, year }

class DateRangeHelper {
  /// Returns a map
  static Map<String, DateTime> getRange(TimeRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case TimeRange.today:
        return {
          'start': today,
          'end': today.add(const Duration(days: 1)),
        };
      case TimeRange.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return {'start': start, 'end': end};
      case TimeRange.thisMonth:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 1);
        return {'start': start, 'end': end};
      case TimeRange.thisYear:
        final start = DateTime(today.year, 1, 1);
        final end = DateTime(today.year + 1, 1, 1);
        return {'start': start, 'end': end};
      case TimeRange.allTime:
        final start = DateTime(2000);
        return {'start': start, 'end': today.add(const Duration(days: 1))};
      case TimeRange.custom:
        final start = today.subtract(const Duration(days: 7));
        return {'start': start, 'end': today.add(const Duration(days: 1))};
    }
  }

  /// Determines how to group the data for the chart
  static GroupUnit getGroupUnit(TimeRange range, DateTime start, DateTime end) {
    switch (range) {
      case TimeRange.today:
      case TimeRange.thisWeek:
      case TimeRange.thisMonth:
        return GroupUnit.day;
      case TimeRange.thisYear:
        return GroupUnit.month;
      case TimeRange.allTime:
        return GroupUnit.year;
      case TimeRange.custom:
        final diff = end.difference(start).inDays;
        if (diff <= 31) return GroupUnit.day;
        if (diff <= 365) return GroupUnit.month;
        return GroupUnit.year;
    }
  }

  ///  helper to display range as text
  static String rangeLabel(TimeRange range) {
    final rangeMap = getRange(range);
    final f = DateFormat('dd/MM');
    return "${f.format(rangeMap['start']!)} - ${f.format(rangeMap['end']!.subtract(const Duration(days: 1)))}";
  }

  /// Create a key for grouping
  static String makeGroupKey(DateTime date, GroupUnit unit) {
    switch (unit) {
      case GroupUnit.day:
        return "${date.year}-${date.month}-${date.day}";
      case GroupUnit.month:
        return "${date.year}-${date.month}";
      case GroupUnit.year:
        return "${date.year}";
    }
  }

  /// Format label for x-axis
  static String formatLabel(String key, GroupUnit unit) {
    final parts = key.split('-');
    switch (unit) {
      case GroupUnit.day:
        return "${parts[2]}/${parts[1]}"; // day/month
      case GroupUnit.month:
        final monthNames = [
          "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];
        final month = int.parse(parts[1]);
        return monthNames[month];
      case GroupUnit.year:
        return parts[0];
    }
  }
}
