import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../../services/habit_service.dart';
import '../../services/habit_log_service.dart';

class LibraryHabitSection extends StatefulWidget {
  const LibraryHabitSection({super.key});

  @override
  State<LibraryHabitSection> createState() => _LibraryHabitSectionState();
}

class _LibraryHabitSectionState extends State<LibraryHabitSection> {
  final _habitService = HabitService();
  final _habitLogService = HabitLogService();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, List<HabitLog>> _logs = {};

  @override
  void initState() {
    super.initState();
    _fetchAllLogs();
  }

  Future<void> _fetchAllLogs() async {
    // Lấy toàn bộ logs trong tháng đang chọn
    final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final query = await _habitLogService.getLogsBetween(start, end);
    setState(() {
      _logs = {};
      for (var log in query) {
        _logs.putIfAbsent(log.habitId, () => []).add(log);
      }
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _fetchAllLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Habit>>(
      stream: _habitService.getHabits(),
      builder: (context, snapshot) {
        final habits = snapshot.data ?? [];

        if (habits.isEmpty) {
          return const Center(child: Text("No habits found"));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _pickMonth,
                    icon: const Icon(Icons.calendar_today,
                        color: Colors.deepPurple),
                    label: Text(
                      '${_selectedMonth.month}/${_selectedMonth.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _fetchAllLogs,
                    icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final logs = _logs[habit.id] ?? [];
                  return _buildHabitCalendar(habit, logs);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitCalendar(Habit habit, List<HabitLog> logs) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Habit name ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              habit.name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          // --- Calendar ---
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedMonth,
            currentDay: DateTime.now(),
            availableGestures: AvailableGestures.none,
            headerVisible: false,
            daysOfWeekVisible: true,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final weekdayStr = _weekdayString(day.weekday);
                final isHabitDay = habit.daysOfWeek.contains(weekdayStr);
                final log = logs.firstWhere(
                  (l) => l.dayKey == "${day.year}-${day.month}-${day.day}",
                  orElse: () => HabitLog(
                    id: '',
                    habitId: habit.id,
                    userId: habit.userId,
                    dayKey: '',
                    done: false,
                  ),
                );

                return GestureDetector(
                  onTap: isHabitDay
                      ? () async {
                          await _habitLogService.toggleHabit(
                              habit.id, day, log.done);
                          _fetchAllLogs();
                        }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: log.done
                          ? Colors.deepPurple.withOpacity(0.7)
                          : (isHabitDay
                              ? Colors.deepPurple.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color:
                            isHabitDay ? Colors.black : Colors.grey.shade400,
                        fontWeight:
                            log.done ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "";
    }
  }
}
