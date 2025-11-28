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
      appBar: AppBar(
        title: const Text('My Schedule'),
        elevation: 0,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Calendar card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
                        icon: const Icon(Icons.chevron_left, size: 22),
                        onPressed: _previousMonth,
                        color: Colors.deepPurple.shade400,
                      ),
                      Text(
                        "${_focusedDay.month}/${_focusedDay.year}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.deepPurple.shade400,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 22),
                        onPressed: _nextMonth,
                        color: Colors.deepPurple.shade400,
                      ),
                    ],
                  ),
                ),

                // Top-right toggle button
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      _calendarFormat == CalendarFormat.month
                          ? Icons.view_week
                          : Icons.view_module,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: _toggleCalendarFormat,
                  ),
                ),

                // Calendar widget
                Padding(
                  padding: const EdgeInsets.only(top: 55),
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
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepPurple.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerVisible: false,
                    rowHeight: 46,
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
        backgroundColor: Colors.deepPurple.shade400,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
