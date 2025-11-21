import 'package:flutter/material.dart';

enum TimeRange {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  allTime,
}

class TimeRangeDropdown extends StatelessWidget {
  final TimeRange selected;
  final Function(TimeRange) onChanged;

  const TimeRangeDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TimeRange>(
      value: selected,
      onChanged: (v) => onChanged(v!),
      items: TimeRange.values.map((r) {
        return DropdownMenuItem(
          value: r,
          child: Text(_label(r)),
        );
      }).toList(),
    );
  }

  String _label(TimeRange r) {
    switch (r) {
      case TimeRange.today:
        return "Today";
      case TimeRange.thisWeek:
        return "This Week";
      case TimeRange.thisMonth:
        return "This Month";
      case TimeRange.thisYear:
        return "This Year";
      case TimeRange.allTime:
        return "All Time";
    }
  }
}