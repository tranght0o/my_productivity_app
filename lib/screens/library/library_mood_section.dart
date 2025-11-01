import 'package:flutter/material.dart';
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

  // Store all moods grouped by day key (example: "2025-10-31")
  Map<String, Mood> _moodByDay = {};

  // Track which day is currently focused in the calendar
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  /// Fetch all moods from Firestore once and group them by day key
  Future<void> _fetchMoods() async {
    final moods = await _moodService.getAllMoodsOnce();
    setState(() {
      _moodByDay = {for (var m in moods) _dayKeyFromDate(m.date): m};
    });
  }

  /// Helper function to convert a DateTime into a string key (yyyy-MM-dd)
  String _dayKeyFromDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Map a numeric mood value to a simple text label
  String _labelForValue(int value) {
    switch (value) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return '';
    }
  }

  /// Display a dialog to view or edit the note of a specific mood
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
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Text(
              'Mood Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Main calendar widget
          TableCalendar(
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
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            // Custom UI for calendar cells
            calendarBuilders: CalendarBuilders(
              // Default day cell
              defaultBuilder: (context, day, _) {
                final key = _dayKeyFromDate(day);
                final Mood? mood = _moodByDay[key];

                // No mood saved for this day
                if (mood == null || mood.moodValue == 0) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }

                // Mood exists for this day
                return GestureDetector(
                  onTap: () => _showNoteDialogForDay(day, mood),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labelForValue(mood.moodValue),
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },

              // Today cell with border
              todayBuilder: (context, day, _) {
                final key = _dayKeyFromDate(day);
                final Mood? mood = _moodByDay[key];

                return GestureDetector(
                  onTap:
                      mood != null ? () => _showNoteDialogForDay(day, mood) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (mood != null && mood.moodValue != 0)
                            Text(
                              _labelForValue(mood.moodValue),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
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
}
