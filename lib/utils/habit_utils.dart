import '../models/habit_model.dart';

/// Utility functions to help with habit logic
/// (used in both HabitSection and LibraryHabitSection)
class HabitUtils {
  /// Check if a given [day] should show this [habit]
  /// based on startDate, endDate, frequency, and repeat days.
  static bool isHabitActiveOnDay(Habit habit, DateTime day) {
    // Check start and end date range
    if (day.isBefore(habit.startDate)) return false;
    if (habit.endDate != null && day.isAfter(habit.endDate!)) return false;

    // Match based on frequency type
    switch (habit.frequency) {
      case 'daily':
        // Daily habits are active every day within range
        return true;

      case 'weekly':
        // For weekly habits → match weekday name
        final weekdayName = _weekdayString(day.weekday);
        return habit.daysOfWeek.contains(weekdayName);

      case 'monthly':
        // For monthly habits → match specific date number
        return habit.daysOfMonth.contains(day.day);

      default:
        return false;
    }
  }

  /// Helper: convert weekday number (1-7) to string like "Mon", "Tue", etc.
  static String _weekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
