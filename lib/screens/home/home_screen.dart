import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/add_todo_bottom_sheet.dart';
import '../../widgets/add_habit_bottom_sheet.dart';
import 'todo_section.dart';
import 'habit_section.dart';
import 'mood_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Show bottom sheet for adding Todo, Habit, or Mood
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('To do'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) =>
                        AddTodoBottomSheet(initialDate: _selectedDay),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Habit'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => const AddHabitBottomSheet(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.mood),
                title: const Text('Mood'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 12),

          // Sections
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TodoSection(selectedDay: _selectedDay),
                  const SizedBox(height: 16),
                  HabitSection(selectedDay: _selectedDay),
                  const SizedBox(height: 16),
                  const MoodSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add),
      ),
    );
  }
}
