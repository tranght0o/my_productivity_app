import '../models/habit_model.dart';

/// Utility class for handling habit-related logic.
/// Used by both HabitSection and LibraryHabitSection.
class HabitUtils {
  /// Determine if a given [habit] should appear on [day].
  /// It respects startDate, endDate, and frequency rules.
  static bool isHabitActiveOnDay(Habit habit, DateTime day) {
    // 1. Check startDate and endDate boundaries
    if (day.isBefore(habit.startDate)) return false;
    if (habit.endDate != null && day.isAfter(habit.endDate!)) return false;

    // 2. Frequency-based logic
    switch (habit.frequency) {
      case 'daily':
        // Daily habits occur every day within range
        return true;

      case 'weekly':
        // Weekly habits depend on day of week, e.g. Mon, Wed, Fri
        final weekday = _weekdayString(day.weekday);
        return habit.daysOfWeek.contains(weekday);

      case 'monthly':
        // Monthly habits repeat on specific days (1, 15, etc.)
        return habit.daysOfMonth.contains(day.day);

      default:
        return false;
    }
  }

  /// Helper: convert weekday number (1–7) to a short string like "Mon", "Tue", etc.
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

  /// Calculate completion percentage for a given [habit] in a month.
  /// [doneDays] is a list of completed day numbers.
  static double calculateCompletion({
    required Habit habit,
    required List<int> doneDays,
    required int totalDays,
  }) {
    if (totalDays == 0) return 0;
    final completed = doneDays.length;
    return (completed / totalDays) * 100;
  }

  /// Calculate streak count for a habit based on consecutive days done.
  /// [sortedDays] should be a sorted list of completed DateTimes.
  static int calculateStreak(List<DateTime> sortedDays) {
    if (sortedDays.isEmpty) return 0;
    int streak = 1;

    for (int i = sortedDays.length - 1; i > 0; i--) {
      final diff = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
