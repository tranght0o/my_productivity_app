import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../../services/habit_log_service.dart';
import '../../utils/habit_utils.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _habitLogService = HabitLogService();
  
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<HabitLog> _logs = [];
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final logs = await _habitLogService.getLogsByMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
      
      if (mounted) {
        setState(() {
          _logs = logs.where((log) => log.habitId == widget.habit.id).toList();
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load logs: $e')),
        );
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
    _fetchLogs();
  }

  String _getFrequencyText() {
    switch (widget.habit.frequency) {
      case 'daily':
        return 'Everyday';
      case 'weekly':
        return 'Every ${widget.habit.daysOfWeek.join(", ")}';
      case 'monthly':
        return 'Every ${widget.habit.daysOfMonth.join(", ")}';
      default:
        return '';
    }
  }

  int _calculateStreak() {
    if (_logs.isEmpty) return 0;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final completedLogs = _logs.where((log) => log.done).toList();
    if (completedLogs.isEmpty) return 0;

    final completedDates = completedLogs.map((log) {
      final parts = log.dayKey.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? checkDate = normalizedToday;

    bool foundStart = false;
    for (var date in completedDates) {
      if (date.isAfter(normalizedToday)) continue;
      
      final daysSince = normalizedToday.difference(date).inDays;
      if (daysSince <= 1) {
        foundStart = true;
        streak = 1;
        checkDate = date;
        break;
      }
    }

    if (!foundStart) return 0;

    checkDate = checkDate!.subtract(const Duration(days: 1));
    
    while (true) {
      DateTime? nextValidDay;
      for (int i = 0; i < 14; i++) {
        final candidateDay = checkDate!.subtract(Duration(days: i));
        if (HabitUtils.isHabitActiveOnDay(widget.habit, candidateDay)) {
          nextValidDay = candidateDay;
          break;
        }
      }

      if (nextValidDay == null) break;

      final wasCompleted = completedDates.any((d) =>
          d.year == nextValidDay!.year &&
          d.month == nextValidDay.month &&
          d.day == nextValidDay.day);

      if (wasCompleted) {
        streak++;
        checkDate = nextValidDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  double _calculateCompletion() {
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    int totalDays = 0;
    int doneDays = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, d);
      if (!HabitUtils.isHabitActiveOnDay(widget.habit, date)) continue;

      totalDays++;
      final match = _logs.any(
        (l) => l.dayKey == "${date.year}-${date.month}-${date.day}" && l.done,
      );
      if (match) doneDays++;
    }

    if (totalDays == 0) return 0;
    return (doneDays / totalDays) * 100;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.habit.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final streak = _calculateStreak();
    final completion = _calculateCompletion();
    final purple = Colors.deepPurple.shade400;

    // Prepare short start-end text
    final startText = _formatDate(widget.habit.startDate);
    final endText = widget.habit.endDate != null
        ? _formatDate(widget.habit.endDate!)
        : 'No end date';
    final startEndText = '$startText - $endText';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 16),

            // -------------------------------
            // 🔥 Stats card (main card)
            // -------------------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Header row: frequency + inline date pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getFrequencyText(),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Date range pill (clean, minimal)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          startEndText,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Streak + completion row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$streak',
                            style: TextStyle(
                              color: purple,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Streak',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),

                      Column(
                        children: [
                          Text(
                            '${completion.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: purple,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completion',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: 26),

            // -------------------------------
            // 🔥 Month navigation card
            // -------------------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Icon(Icons.chevron_left, color: purple),
                    onTap: () => _changeMonth(-1),
                  ),
                  Text(
                    '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  InkWell(
                    child: Icon(Icons.chevron_right, color: purple),
                    onTap: () => _changeMonth(1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // 🔥 Calendar card
            // -------------------------------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _currentMonth,
                currentDay: DateTime.now(),
                availableGestures: AvailableGestures.none,
                headerVisible: false,
                daysOfWeekVisible: true,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildDayCell(day);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildDayCell(day);
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    final isValid = HabitUtils.isHabitActiveOnDay(widget.habit, day);
    final log = _logs.firstWhere(
      (l) => l.dayKey == "${day.year}-${day.month}-${day.day}",
      orElse: () => HabitLog(
        id: '',
        habitId: widget.habit.id,
        userId: widget.habit.userId,
        dayKey: '',
        done: false,
      ),
    );

    final purple = Colors.deepPurple.shade400;
    final bool isDone = log.done && isValid;

    final Color bgColor = !isValid
        ? Colors.grey.withOpacity(0.06)
        : (isDone ? purple : purple.withOpacity(0.12));

    final Color textColor = !isValid
        ? Colors.grey.withOpacity(0.4)
        : (isDone ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: isValid
          ? () async {
              try {
                await _habitLogService.toggleHabit(
                  widget.habit.id,
                  day,
                  log.done,
                );
                _fetchLogs();
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
        margin: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
