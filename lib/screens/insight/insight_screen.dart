// lib/screens/insight/insight_screen.dart
import 'package:flutter/material.dart';
import 'widgets/todo_chart.dart';
import 'widgets/habit_chart.dart';
import 'widgets/mood_chart.dart';
import 'widgets/insight_summary.dart';

/// Main Insight Screen - Now simplified to show weekly data only
/// User can navigate between weeks using arrow buttons
class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  // Currently selected week (represented by any date in that week)
  DateTime _selectedWeek = DateTime.now();

  /// Get the Monday of the week containing the given date
  DateTime _getMonday(DateTime date) {
    // DateTime.monday = 1, Sunday = 7
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Get Sunday of the week (last day)
  DateTime _getSunday(DateTime date) {
    final monday = _getMonday(date);
    return monday.add(const Duration(days: 6));
  }

  /// Move to previous week
  void _previousWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    });
  }

  /// Move to next week
  void _nextWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    });
  }

  /// Reset to current week
  void _goToCurrentWeek() {
    setState(() {
      _selectedWeek = DateTime.now();
    });
  }

  /// Check if selected week is the current week
  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentMonday = _getMonday(now);
    final selectedMonday = _getMonday(_selectedWeek);
    return currentMonday.isAtSameMomentAs(selectedMonday);
  }

  /// Format week range for display: "1-7 Dec" or "28 Nov - 4 Dec"
  String _getWeekLabel() {
    final monday = _getMonday(_selectedWeek);
    final sunday = _getSunday(_selectedWeek);

    // Month names
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    // If same month
    if (monday.month == sunday.month) {
      return '${monday.day}-${sunday.day} ${months[monday.month]}';
    } else {
      // Different months (e.g., week spanning Nov-Dec)
      return '${monday.day} ${months[monday.month]} - ${sunday.day} ${months[sunday.month]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Week Selector Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous week button
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.deepPurple,
                  onPressed: _previousWeek,
                  tooltip: 'Previous week',
                ),

                // Week label and "Today" button
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Week ${_getWeekLabel()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Show "Today" button if not on current week
                      if (!_isCurrentWeek())
                        TextButton(
                          onPressed: _goToCurrentWeek,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Go to this week',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

                // Next week button
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: Colors.deepPurple,
                  onPressed: _nextWeek,
                  tooltip: 'Next week',
                ),
              ],
            ),
          ),

          // Scrollable content with summary and charts
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Summary card - shows stats for selected week
                  InsightSummary(selectedWeek: _selectedWeek),
                  const SizedBox(height: 16),

                  // Todo completion chart (7 days)
                  TodoChart(selectedWeek: _selectedWeek),
                  const SizedBox(height: 8),

                  // Habit completion chart (7 days)
                  HabitChart(selectedWeek: _selectedWeek),
                  const SizedBox(height: 8),

                  // Mood trend chart (7 days)
                  MoodChart(selectedWeek: _selectedWeek),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}