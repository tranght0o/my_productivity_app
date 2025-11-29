import 'package:flutter/material.dart';
import '../../../services/todo_service.dart';
import '../../../services/habit_log_service.dart';
import '../../../services/mood_service.dart';

/// Summary card showing weekly statistics
/// Displays: total/completed tasks, habits, and average mood
class InsightSummary extends StatefulWidget {
  final DateTime selectedWeek; // Any date in the target week

  const InsightSummary({super.key, required this.selectedWeek});

  @override
  State<InsightSummary> createState() => _InsightSummaryState();
}

class _InsightSummaryState extends State<InsightSummary> {
  final _todoService = TodoService();
  final _habitLogService = HabitLogService();
  final _moodService = MoodService();

  // Week statistics
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalHabits = 0;
  int _completedHabits = 0;
  double _avgMood = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  @override
  void didUpdateWidget(InsightSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when week changes
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _loadWeeklyData();
    }
  }

  /// Get Monday of the week
  DateTime _getMonday(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Load statistics for the selected week (Monday to Sunday)
  Future<void> _loadWeeklyData() async {
    setState(() => _loading = true);

    try {
      // Calculate week boundaries
      final monday = _getMonday(widget.selectedWeek);
      final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

      // Load todos for the week
      final todos = await _todoService.getTodosBetween(monday, sunday);
      _totalTasks = todos.length;
      _completedTasks = todos.where((t) => t.done).length;

      // Load habit logs for the week
      final logs = await _habitLogService.getLogsBetween(monday, sunday);
      _totalHabits = logs.length;
      _completedHabits = logs.where((h) => h.done).length;

      // Load moods for the week and calculate average
      final moods = await _moodService.getMoodsBetween(monday, sunday);
      if (moods.isNotEmpty) {
        final totalMood = moods.fold<int>(0, (sum, m) => sum + m.moodValue);
        _avgMood = totalMood / moods.length;
      } else {
        _avgMood = 0;
      }

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  /// Get emoji for mood value
  String _getMoodEmoji(double avg) {
    if (avg == 0) return '😐';
    if (avg >= 4.5) return '🤩';
    if (avg >= 3.5) return '😊';
    if (avg >= 2.5) return '😐';
    if (avg >= 1.5) return '😞';
    return '😢';
  }

  /// Get label for mood value
  String _getMoodLabel(double avg) {
    if (avg == 0) return 'No data';
    if (avg >= 4.5) return 'Amazing';
    if (avg >= 3.5) return 'Good';
    if (avg >= 2.5) return 'Okay';
    if (avg >= 1.5) return 'Bad';
    return 'Terrible';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate percentages
    final taskPercentage = _totalTasks == 0 
        ? 0 
        : (_completedTasks / _totalTasks * 100).toInt();
    final habitPercentage = _totalHabits == 0 
        ? 0 
        : (_completedHabits / _totalHabits * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              // Tasks Card
              Expanded(
                child: _buildStatCard(
                  icon: Icons.task_alt,
                  iconColor: Colors.blue,
                  title: 'Tasks',
                  value: '$_completedTasks/$_totalTasks',
                  subtitle: '$taskPercentage%',
                  backgroundColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(width: 8),

              // Habits Card
              Expanded(
                child: _buildStatCard(
                  icon: Icons.repeat,
                  iconColor: Colors.purple,
                  title: 'Habits',
                  value: '$_completedHabits/$_totalHabits',
                  subtitle: '$habitPercentage%',
                  backgroundColor: Colors.purple.shade50,
                ),
              ),
              const SizedBox(width: 8),

              // Mood Card
              Expanded(
                child: _buildStatCard(
                  icon: Icons.mood,
                  iconColor: Colors.orange,
                  title: 'Avg Mood',
                  value: '${_getMoodEmoji(_avgMood)} ${_getMoodLabel(_avgMood)}',
                  subtitle: _avgMood > 0 
                      ? '${_avgMood.toStringAsFixed(1)}/5' 
                      : 'No data',
                  backgroundColor: Colors.orange.shade50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}