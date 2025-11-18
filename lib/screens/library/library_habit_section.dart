import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../../services/habit_service.dart';
import '../../services/habit_log_service.dart';
import '../../utils/habit_utils.dart';

class LibraryHabitSection extends StatefulWidget {
  final String searchQuery;
  const LibraryHabitSection({super.key, this.searchQuery = ''});

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

  /// Fetch logs for selected month (OPTIMIZED)
  Future<void> _fetchAllLogs() async {
    try {
      final logs = await _habitLogService.getLogsByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );

      setState(() {
        _logs = {};
        for (var log in logs) {
          _logs.putIfAbsent(log.habitId, () => []).add(log);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load habit logs: $e')),
        );
      }
    }
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

        final filteredHabits = widget.searchQuery.isEmpty
            ? habits
            : habits
                .where((h) => h.name
                    .toLowerCase()
                    .contains(widget.searchQuery.toLowerCase()))
                .toList();

        if (filteredHabits.isEmpty) {
          return const Center(
            child: Text(
              'No habits found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            // Month picker header
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

            // Habits list
            Expanded(
              child: ListView.builder(
                itemCount: filteredHabits.length,
                itemBuilder: (context, index) {
                  final habit = filteredHabits[index];
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
    final streak = _calculateStreak(logs);
    final completion = _calculateCompletion(habit, logs);

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              habit.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedMonth,
            currentDay: DateTime.now(),
            availableGestures: AvailableGestures.none,
            headerVisible: false,
            daysOfWeekVisible: true,
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final isValid = HabitUtils.isHabitActiveOnDay(habit, day);
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

                final bgColor = !isValid
                    ? Colors.grey.withOpacity(0.05)
                    : (log.done
                        ? Colors.deepPurple.withOpacity(0.7)
                        : Colors.deepPurple.withOpacity(0.1));

                final textColor =
                    isValid ? Colors.black : Colors.grey.withOpacity(0.4);

                return GestureDetector(
                  onTap: isValid
                      ? () async {
                          try {
                            await _habitLogService.toggleHabit(
                              habit.id,
                              day,
                              log.done,
                            );
                            _fetchAllLogs();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: $e')),
                              );
                            }
                          }
                        }
                      : null,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight:
                            log.done ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🔥 Streak: $streak days',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  '✅ ${completion.toStringAsFixed(0)}% done',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<HabitLog> logs) {
    if (logs.isEmpty) return 0;
    logs.sort((a, b) => a.dayKey.compareTo(b.dayKey));
    int streak = 0;
    DateTime today = DateTime.now();

    for (int i = logs.length - 1; i >= 0; i--) {
      final parts = logs[i].dayKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      if (!logs[i].done || date.isAfter(today)) continue;

      final diff = today.difference(date).inDays;
      if (diff == streak) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double _calculateCompletion(Habit habit, List<HabitLog> logs) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
    int totalDays = 0;
    int doneDays = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, d);
      if (!HabitUtils.isHabitActiveOnDay(habit, date)) continue;

      totalDays++;
      final match = logs.any(
        (l) =>
            l.dayKey == "${date.year}-${date.month}-${date.day}" && l.done,
      );
      if (match) doneDays++;
    }

    if (totalDays == 0) return 0;
    return (doneDays / totalDays) * 100;
  }
}