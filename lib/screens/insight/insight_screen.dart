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
      appBar: AppBar(title: const Text("Insights")),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            InsightSummary(),
            TodoChart(),
            HabitChart(),
            MoodChart(),
          ],
        ),
      ),
    );
  }
}
