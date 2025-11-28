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

  //mood options and values
  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😢', 'value': 1, 'label': 'Terrible'},
    {'emoji': '😞', 'value': 2, 'label': 'Bad'},
    {'emoji': '😐', 'value': 3, 'label': 'Okay'},
    {'emoji': '😊', 'value': 4, 'label': 'Good'},
    {'emoji': '🤩', 'value': 5, 'label': 'Amazing'},
  ];

  int? _tempSelected;

  /// Save the mood to Firestore and update local state for instant UI feedback
  Future<void> _saveMood(int value) async {
    setState(() {
      _tempSelected = value;
    });
    
    try {
      await _moodService.addOrUpdateMood(widget.selectedDay, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save mood: $e')),
        );
      }
    }
  }

  String _getLabelForValue(int value) {
    final mood = _moodOptions.firstWhere(
      (m) => m['value'] == value,
      orElse: () => {'label': 'Unknown'},
    );
    return mood['label'];
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
          final currentValue = currentMood?.moodValue ?? _tempSelected;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'How are you feeling?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (currentValue != null)
                      Text(
                        _getLabelForValue(currentValue),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Mood Emoji Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _moodOptions.map((m) {
                    final bool selected = currentValue == m['value'];
                    return GestureDetector(
                      onTap: () => _saveMood(m['value']),
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
              ),

              const SizedBox(height: 16),
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
      });
    }
  }
}
