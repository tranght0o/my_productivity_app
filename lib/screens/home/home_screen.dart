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

  // Default open as WEEK mode
  CalendarFormat _calendarFormat = CalendarFormat.week;

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

  // Move to previous based on mode
  void _previousMonth() {
    setState(() {
      if (_calendarFormat == CalendarFormat.week) {
        _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      }
    });
  }

  // Move to next based on mode
  void _nextMonth() {
    setState(() {
      if (_calendarFormat == CalendarFormat.week) {
        _focusedDay = _focusedDay.add(const Duration(days: 7));
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      }
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
    String greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return "Good Morning";
      if (hour < 17) return "Good Afternoon";
      return "Good Evening";
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F6FA),
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting(),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(221, 28, 28, 28),
                ),
            ),
          ],
        ),
      ),

      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // Calendar card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
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
                          fontSize: 17,
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

                Padding(
                  padding: const EdgeInsets.only(top: 60),
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
                        color: Colors.deepPurple.shade400,
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

          const SizedBox(height: 10),

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
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
