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
        // --- Header: month picker + refresh ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _pickMonth,
                icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                label: Text(
                  '${_selectedMonth.month}/${_selectedMonth.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              IconButton(
                onPressed: _fetchMoods,
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
              ),
            ],
          ),
        ),

        // --- Calendar Card ---
        Expanded(
          child: SingleChildScrollView(
            child: Container(
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
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    _dayKeyFromDate(day) == _dayKeyFromDate(_focusedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                headerVisible: false,

                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(), // remove default purple circle
                  rowDecoration: BoxDecoration(),
                  tablePadding: EdgeInsets.only(top: 8), // add spacing above weekdays
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    final key = _dayKeyFromDate(day);
                    final Mood? mood = _moodByDay[key];
                    final bool isToday = _dayKeyFromDate(day) ==
                        _dayKeyFromDate(DateTime.now());

                    return GestureDetector(
                      onTap: mood != null
                          ? () => _showNoteDialogForDay(day, mood)
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 3),
                          if (mood != null && mood.moodValue > 0)
                            Text(
                              _emojiForValue(mood.moodValue),
                              style: const TextStyle(fontSize: 22),
                            )
                          else if (isToday)
                            // ✅ Small dot under today
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
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
}
