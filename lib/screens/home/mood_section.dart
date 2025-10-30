import 'package:flutter/material.dart';
import '../../services/mood_service.dart';
import '../../models/mood_model.dart';

class MoodSection extends StatefulWidget {
  final DateTime selectedDay;
  const MoodSection({super.key, required this.selectedDay});

  @override
  State<MoodSection> createState() => _MoodSectionState();
}

class _MoodSectionState extends State<MoodSection> {
  final _moodService = MoodService();
  final TextEditingController _noteController = TextEditingController();

  // Mood options (emoji + value)
  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😞', 'value': 1},
    {'emoji': '😐', 'value': 2},
    {'emoji': '🙂', 'value': 3},
    {'emoji': '😄', 'value': 4},
    {'emoji': '🤩', 'value': 5},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Save mood instantly when selected
  Future<void> _saveMood(int value, String? note) async {
    await _moodService.addOrUpdateMood(widget.selectedDay, value, note);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: StreamBuilder<Mood?>(
        stream: _moodService.getMoodForDay(widget.selectedDay),
        builder: (context, snapshot) {
          final currentMood = snapshot.data;
          final currentValue = currentMood?.moodValue ?? 0;

          // Keep the note field synced
          if (currentMood?.note != null &&
              _noteController.text != currentMood!.note) {
            _noteController.text = currentMood.note!;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- Section title -----
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Mood',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // ----- Emoji row -----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _moodOptions.map((m) {
                    final selected = currentValue == m['value'];
                    return GestureDetector(
                      onTap: () => _saveMood(m['value'], _noteController.text),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected ? Colors.deepPurple[50] : null,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          m['emoji'],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // ----- Optional note input -----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Add a note (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save, color: Colors.deepPurple),
                      onPressed: () =>
                          _saveMood(currentValue, _noteController.text),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
