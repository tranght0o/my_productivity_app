import 'package:flutter/material.dart';
import 'widgets/todo_chart.dart';
import 'widgets/habit_chart.dart';
import 'widgets/mood_chart.dart';
import 'widgets/insight_summary.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 8),
            InsightSummary(),
            SizedBox(height: 16),
            TodoChart(),
            SizedBox(height: 8),
            HabitChart(),
            SizedBox(height: 8),
            MoodChart(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}