import 'package:intl/intl.dart';
import '../screens/insight/widgets/time_range_dropdown.dart';

/// Helper to calculate start and end dates based on TimeRange selection.
class DateRangeHelper {
  /// Returns a map: { 'start': DateTime, 'end': DateTime }
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

      case TimeRange.lastMonth:
        final start = DateTime(today.year, today.month - 1, 1);
        final end = DateTime(today.year, today.month, 1);
        return {'start': start, 'end': end};

      case TimeRange.last6Months:
        final start = DateTime(today.year, today.month - 5, 1);
        return {'start': start, 'end': today.add(const Duration(days: 1))};

      case TimeRange.thisYear:
        final start = DateTime(today.year, 1, 1);
        final end = DateTime(today.year + 1, 1, 1);
        return {'start': start, 'end': end};

      case TimeRange.lastYear:
        final start = DateTime(today.year - 1, 1, 1);
        final end = DateTime(today.year, 1, 1);
        return {'start': start, 'end': end};

      case TimeRange.allTime:
        final start = DateTime(2000);
        return {'start': start, 'end': today.add(const Duration(days: 1))};

      case TimeRange.custom:
        // Nếu sau này bạn muốn chọn range thủ công bằng date picker
        // thì sẽ thay giá trị ở đây.
        final start = today.subtract(const Duration(days: 7));
        return {'start': start, 'end': today.add(const Duration(days: 1))};
    }
  }

  /// Optional helper to display range as text
  static String rangeLabel(TimeRange range) {
    final rangeMap = getRange(range);
    final f = DateFormat('dd/MM');
    return "${f.format(rangeMap['start']!)} - ${f.format(rangeMap['end']!.subtract(const Duration(days: 1)))}";
  }
}
