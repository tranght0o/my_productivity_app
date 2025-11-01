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

  CalendarFormat _calendarFormat = CalendarFormat.month;

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

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat =
          _calendarFormat == CalendarFormat.month ? CalendarFormat.week : CalendarFormat.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Calendar card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Centered Month/Year with arrows
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 24),
                        onPressed: _previousMonth,
                        color: Colors.deepPurple,
                      ),
                      Text(
                        "${_focusedDay.month}/${_focusedDay.year}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 24),
                        onPressed: _nextMonth,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),

                // Top-right toggle button (grey, subtle)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      _calendarFormat == CalendarFormat.month
                          ? Icons.view_week
                          : Icons.view_module,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: _toggleCalendarFormat,
                  ),
                ),

                // Calendar widget with padding for header
                Padding(
                  padding: const EdgeInsets.only(top: 50), // add space between title and weekdays
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    headerVisible: false,
                    rowHeight: 48,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main sections
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TodoSection(selectedDay: _selectedDay),
                  const SizedBox(height: 16),
                  HabitSection(selectedDay: _selectedDay),
                  const SizedBox(height: 16),
                  MoodSection(selectedDay: _selectedDay),
                  const SizedBox(height: 16),
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
