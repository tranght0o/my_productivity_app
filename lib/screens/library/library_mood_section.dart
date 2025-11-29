import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/mood_model.dart';
import '../../services/mood_service.dart';
import '../../widgets/mood_picker_bottom_sheet.dart';

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

  // Mood options
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
  }

  // Stream moods for selected month (Realtime)
  Stream<Map<String, Mood>> _moodStream() {
    final y = _selectedMonth.year;
    final m = _selectedMonth.month;
    return _moodService
        .getMoodsByMonthStream(y, m)
        .map((list) => {for (var m in list) _dayKeyFromDate(m.date): m});
  }

  // Month picker
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

  // Mood Picker BottomSheet
  void _showMoodPicker(DateTime day) {
    final currentMood = _moodByDay[_dayKeyFromDate(day)];
    int? selectedValue = currentMood?.moodValue;

    showMoodPickerBottomSheet(
      context: context,
      day: day,
      moodOptions: {
        for (var m in _moodOptions) m['value']: m,
      },
      moodService: _moodService,
      currentValue: selectedValue,
    );
  }

  Map<int, int> _getMoodCounts() {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var mood in _moodByDay.values) {
      if (counts.containsKey(mood.moodValue)) {
        counts[mood.moodValue] = counts[mood.moodValue]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Mood>>(
      stream: _moodStream(),
      builder: (context, snapshot) {
        _moodByDay = snapshot.data ?? {};
        return Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Calendar card
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      // Month Switcher and card
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 22),
                                onPressed: () {
                                  setState(() {
                                    _selectedMonth = DateTime(
                                        _selectedMonth.year,
                                        _selectedMonth.month - 1);
                                    _focusedDay = _selectedMonth;
                                  });
                                },
                                color: Colors.deepPurple.shade400,
                              ),
                              GestureDetector(
                                onTap: _pickMonth,
                                child: Text(
                                  '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.deepPurple.shade400,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 22),
                                onPressed: () {
                                  setState(() {
                                    _selectedMonth = DateTime(
                                        _selectedMonth.year,
                                        _selectedMonth.month + 1);
                                    _focusedDay = _selectedMonth;
                                  });
                                },
                                color: Colors.deepPurple.shade400,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          TableCalendar(
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
                                _selectedMonth =
                                    DateTime(focusedDay.year, focusedDay.month);
                              });
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
                              tablePadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              cellMargin: const EdgeInsets.all(4),
                              defaultTextStyle:
                                  const TextStyle(fontSize: 12),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, _) =>
                                  _buildDayCell(day),
                              todayBuilder: (context, day, _) =>
                                  _buildDayCell(day),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mood count
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
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
                              final count =
                                  _getMoodCounts()[m['value']] ?? 0;
                              return Column(
                                children: [
                                  Text(
                                    m['emoji'],
                                    style: const TextStyle(fontSize: 28),
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
      },
    );
  }

  Widget _buildDayCell(DateTime day) {
    final key = _dayKeyFromDate(day);
    final Mood? mood = _moodByDay[key];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (mood != null && mood.moodValue > 0) ...[
              Text(
                _emojiForValue(mood.moodValue),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Icon(
                    Icons.sentiment_satisfied_outlined,
                    size: 18,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 2),
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
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
