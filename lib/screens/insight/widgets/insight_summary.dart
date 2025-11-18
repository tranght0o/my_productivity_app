import 'package:flutter/material.dart';
import '../../../services/todo_service.dart';
import '../../../services/habit_log_service.dart';

class InsightSummary extends StatefulWidget {
  const InsightSummary({super.key});

  @override
  State<InsightSummary> createState() => _InsightSummaryState();
}

class _InsightSummaryState extends State<InsightSummary> {
  final _todoService = TodoService();
  final _habitLogService = HabitLogService();

  int _todoCompleted = 0;
  int _habitCompleted = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // OPTIMIZED: Only load last year of data
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      final now = DateTime.now();

      final todos = await _todoService.getTodosBetween(oneYearAgo, now);
      final logs = await _habitLogService.getLogsBetween(oneYearAgo, now);

      final todoCount = todos.where((t) => t.done).length;
      final habitCount = logs.where((h) => h.done).length;

      setState(() {
        _todoCompleted = todoCount;
        _habitCompleted = habitCount;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildStatCard(
              value: _todoCompleted.toString(),
              label: "To-Dos Completed",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: _habitCompleted.toString(),
              label: "Habits Completed",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}