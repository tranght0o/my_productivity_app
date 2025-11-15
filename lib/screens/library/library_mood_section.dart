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

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  // Fetch all moods once
  Future<void> _fetchMoods() async {
    final moods = await _moodService.getAllMoodsOnce();
    setState(() {
      _moodByDay = {for (var m in moods) _dayKeyFromDate(m.date): m};
    });
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

  // Format date to yyyy-MM-dd key
  String _dayKeyFromDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // Map mood value to emoji
  String _emojiForValue(int value) {
    switch (value) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😄';
      case 5:
        return '🤩';
      default:
        return '';
    }
  }

  // Map mood value to label
  String _labelForValue(int value) {
    switch (value) {
      case 1:
        return 'Bad';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Not Good';
      default:
        return 'Mood';
    }
  }

  // Dialog for note
  void _showNoteDialogForDay(DateTime day, Mood mood) {
    final controller = TextEditingController(text: mood.note ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Note for ${_dayKeyFromDate(day)}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add or edit your note',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _moodService.addOrUpdateMood(
                day,
                mood.moodValue,
                controller.text.trim(),
              );
              if (mounted) {
                Navigator.pop(context);
                _fetchMoods();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Header: month navigation ---
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
                },
                icon: const Icon(Icons.chevron_right, color: Colors.black87),
              ),
            ],
          ),
        ),

        // --- Calendar ---
        Expanded(
          child: SingleChildScrollView(
            child: Container(
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
                  final key = _dayKeyFromDate(selectedDay);
                  final mood = _moodByDay[key];
                  if (mood != null) {
                    _showNoteDialogForDay(selectedDay, mood);
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedMonth = DateTime(focusedDay.year, focusedDay.month);
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
                  tablePadding: const EdgeInsets.symmetric(vertical: 8),
                  cellMargin: const EdgeInsets.all(4),
                  defaultTextStyle: const TextStyle(fontSize: 12),
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final key = _dayKeyFromDate(day);
                    final Mood? mood = _moodByDay[key];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (mood != null && mood.moodValue > 0) ...[
                            // Emoji
                            Text(
                              _emojiForValue(mood.moodValue),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            // Label
                            Text(
                              _labelForValue(mood.moodValue),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Date
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ] else ...[
                            // Empty state with just "Mood" label and date
                            Container(
                              width: 32,
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
                              'Mood',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  todayBuilder: (context, day, _) {
                    final key = _dayKeyFromDate(day);
                    final Mood? mood = _moodByDay[key];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (mood != null && mood.moodValue > 0) ...[
                            Text(
                              _emojiForValue(mood.moodValue),
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _labelForValue(mood.moodValue),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 32,
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
                              'Mood',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
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
