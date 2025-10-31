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

  // all moods loaded once
  List<Mood> _allMoods = [];

  // quick lookup map keyed by "yyyy-MM-dd"
  Map<String, Mood> _moodByDay = {};

  // currently focused day in calendar
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  // load all moods once and build lookup map
  Future<void> _fetchMoods() async {
    final moods = await _moodService.getAllMoodsOnce();
    setState(() {
      _allMoods = moods;
      _moodByDay = {
        for (var m in moods) _dayKeyFromDate(m.date): m,
      };
    });
  }

  // helper: create "yyyy-MM-dd" key from DateTime
  String _dayKeyFromDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // map mood value to emoji
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

  // show dialog to view/edit note for a mood (only if mood exists)
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
              // update mood (same value, updated note)
              await _moodService.addOrUpdateMood(day, mood.moodValue, controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                _fetchMoods(); // refresh
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
          // title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Text(
              'Mood Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => _dayKeyFromDate(day) == _dayKeyFromDate(_focusedDay),
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
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final key = _dayKeyFromDate(day);
                final Mood? mood = _moodByDay[key];

                if (mood == null || mood.moodValue == 0) {
                  // no mood -> just show day number
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }

                // has mood -> show day number + emoji, tappable to edit note
                return GestureDetector(
                  onTap: () => _showNoteDialogForDay(day, mood),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        _emojiForValue(mood.moodValue),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                );
              },

              // highlight today
              todayBuilder: (context, day, _) {
                final key = _dayKeyFromDate(day);
                final Mood? mood = _moodByDay[key];

                if (mood == null || mood.moodValue == 0) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${day.day}',
                          style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => _showNoteDialogForDay(day, mood),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${day.day}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_emojiForValue(mood.moodValue), style: const TextStyle(fontSize: 22)),
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
