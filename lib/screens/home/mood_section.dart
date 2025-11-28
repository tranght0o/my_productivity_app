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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StreamBuilder<Mood?>(
            stream: _moodService.getMoodForDay(widget.selectedDay),
            builder: (context, snapshot) {
              final currentMood = snapshot.data;
              final currentValue = currentMood?.moodValue ?? _tempSelected;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _moodOptions.map((m) {
                      final bool selected = currentValue == m['value'];
                      return GestureDetector(
                        onTap: () => _saveMood(m['value']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.deepPurple.withOpacity(0.12)
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: selected ? 10 : 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            m['emoji'],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
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
