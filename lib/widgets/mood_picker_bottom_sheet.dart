import 'package:flutter/material.dart';
import '../services/mood_service.dart';

// Mood Picker BottomSheet (tách từ LibraryMoodSection)
void showMoodPickerBottomSheet({
  required BuildContext context,
  required DateTime day,
  required Map<String, dynamic> moodOptions,
  required MoodService moodService,
  required int? currentValue,
}) {
  int? selectedValue = currentValue;

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
                Text(
                  'How are you feeling?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Mood emoji row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: moodOptions.entries.map((m) {
                    final isSelected = selectedValue == m.value['value'];
                    return GestureDetector(
                      onTap: () {
                        setModalState(() => selectedValue = m.value['value']);
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
                          m.value['emoji'],
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
                            await moodService.addOrUpdateMood(
                                day, selectedValue!);
                            if (Navigator.canPop(context)) Navigator.pop(context);
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
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
