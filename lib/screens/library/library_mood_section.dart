import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/mood_model.dart';
import '../../services/mood_service.dart';

class LibraryMoodSection extends StatefulWidget {
  const LibraryMoodSection({super.key});

  @override
  State<LibraryMoodSection> createState() => _LibraryMoodSectionState();
}

class _LibraryMoodSectionState extends State<LibraryMoodSection> {
  final _moodService = MoodService();

  Map<String, Mood> _moodByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Mood scale (must match mood_section.dart)
  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😢', 'value': 1, 'label': 'Terrible'},
    {'emoji': '😞', 'value': 2, 'label': 'Bad'},
    {'emoji': '😐', 'value': 3, 'label': 'Okay'},
    {'emoji': '😊', 'value': 4, 'label': 'Good'},
    {'emoji': '🤩', 'value': 5, 'label': 'Amazing'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  /// Fetch moods for the selected month only
  Future<void> _fetchMoods() async {
    try {
      final moods = await _moodService.getMoodsByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      setState(() {
        _moodByDay = {for (var m in moods) _dayKeyFromDate(m.date): m};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load moods: $e')),
        );
      }
    }
  }

  /// Show month picker and reload data
  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _focusedDay = DateTime(picked.year, picked.month);
      });
      _fetchMoods();
    }
  }

  String _dayKeyFromDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _emojiForValue(int value) {
    final match = _moodOptions.firstWhere(
      (m) => m['value'] == value,
      orElse: () => {'emoji': ''},
    );
    return match['emoji'];
  }

  /// Show bottom sheet to select mood (no note)
  void _showMoodPicker(DateTime day) {
    final currentMood = _moodByDay[_dayKeyFromDate(day)];
    int? selectedValue = currentMood?.moodValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'How are you feeling?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5 Emoji buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _moodOptions.map((m) {
                      final isSelected = selectedValue == m['value'];
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedValue = m['value']);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: isSelected
                                ? Border.all(color: Colors.deepPurple, width: 2)
                                : null,
                          ),
                          child: Text(
                            m['emoji'],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedValue == null
                          ? null
                          : () async {
                              try {
                                await _moodService.addOrUpdateMood(
                                  day,
                                  selectedValue!,
                                );
                                if (mounted) {
                                  Navigator.pop(context);
                                  _fetchMoods();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to save: $e')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Calculate mood count statistics
  Map<int, int> _getMoodCounts() {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var mood in _moodByDay.values) {
      if (mood.moodValue >= 1 && mood.moodValue <= 5) {
        counts[mood.moodValue] = counts[mood.moodValue]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header: month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                    _focusedDay = _selectedMonth;
                  });
                  _fetchMoods();
                },
                icon: const Icon(Icons.chevron_left, color: Colors.black87),
              ),
              GestureDetector(
                onTap: _pickMonth,
                child: Text(
                  '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                    _focusedDay = _selectedMonth;
                  });
                  _fetchMoods();
                },
                icon: const Icon(Icons.chevron_right, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Calendar
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Calendar Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    currentDay: _selectedMonth,
                    selectedDayPredicate: (day) => false,
                    onDaySelected: (selectedDay, focusedDay) {
                      _showMoodPicker(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        _selectedMonth = DateTime(focusedDay.year, focusedDay.month);
                      });
                      _fetchMoods();
                    },
                    calendarFormat: CalendarFormat.month,
                    headerVisible: false,
                    daysOfWeekHeight: 40,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                      weekendStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: const BoxDecoration(),
                      rowDecoration: const BoxDecoration(),
                      tablePadding: const EdgeInsets.symmetric(vertical: 8),
                      cellMargin: const EdgeInsets.all(4),
                      defaultTextStyle: const TextStyle(fontSize: 12),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) => _buildDayCell(day),
                      todayBuilder: (context, day, _) => _buildDayCell(day),
                    ),
                  ),
                ),

                // Mood Count Statistics
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Count',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _moodOptions.map((m) {
                          final count = _getMoodCounts()[m['value']] ?? 0;
                          return Column(
                            children: [
                              Text(
                                m['emoji'],
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build individual day cell (emoji + day number, NO label)
  Widget _buildDayCell(DateTime day) {
    final key = _dayKeyFromDate(day);
    final Mood? mood = _moodByDay[key];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (mood != null && mood.moodValue > 0) ...[
            // Has mood: show emoji + day number
            Text(
              _emojiForValue(mood.moodValue),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            // No mood: show empty circle + day number
            Container(
              width: 32, // Same size as emoji
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: Icon(
                  Icons.sentiment_satisfied_outlined,
                  size: 20,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ],
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
