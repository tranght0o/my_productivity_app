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

  // Mood options list: emoji + numeric value
  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😡', 'value': 1},
    {'emoji': '😞', 'value': 2},
    {'emoji': '😐', 'value': 3},
    {'emoji': '😍', 'value': 4},
    {'emoji': '😊', 'value': 5},
  ];

  int? _tempSelected; // temporarily holds the selected mood value for UI highlight

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Save the mood to Firestore and update local state for instant UI feedback
  Future<void> _saveMood(int value, String? note) async {
    setState(() {
      _tempSelected = value; // immediately update highlight in UI
    });
    await _moodService.addOrUpdateMood(widget.selectedDay, value, note);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: StreamBuilder<Mood?>(
        // Listen for real-time updates for the selected day
        stream: _moodService.getMoodForDay(widget.selectedDay),
        builder: (context, snapshot) {
          final currentMood = snapshot.data;

          final currentValue = currentMood?.moodValue ?? _tempSelected;

          if (currentMood?.note != null &&
              _noteController.text != currentMood!.note) {
            _noteController.text = currentMood.note!;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section Title ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Mood',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // --- Mood Emoji Row (Updated Style) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _moodOptions.map((m) {
                    final bool selected = currentValue == m['value'];
                    return GestureDetector(
                      onTap: () => _saveMood(m['value'], _noteController.text),
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
                          border: selected
                              ? Border.all(
                                  color: Colors.deepPurple, width: 2)
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
              ),

              const SizedBox(height: 16),

              // --- Optional Note Input ---
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
                          _saveMood(currentValue ?? 0, _noteController.text),
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

  @override
  void didUpdateWidget(covariant MoodSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      setState(() {
        _tempSelected = null;
        _noteController.clear();
      });
    }
  }
}
