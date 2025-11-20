import 'package:flutter/material.dart';
import '../../services/habit_service.dart';
import '../../services/habit_log_service.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../../widgets/add_habit_bottom_sheet.dart';
import '../../utils/habit_utils.dart'; // for date validation and filtering logic
import '../../utils/message_helper.dart';

class HabitSection extends StatefulWidget {
  final DateTime selectedDay;
  const HabitSection({super.key, required this.selectedDay});

  @override
  State<HabitSection> createState() => _HabitSectionState();
}

class _HabitSectionState extends State<HabitSection> {
  final _habitService = HabitService();
  final _habitLogService = HabitLogService();

  /// Show edit/delete options for a habit
  void _showHabitOptions(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => AddHabitBottomSheet(
                      habitToEdit: habit,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Show confirmation dialog
                  final confirmed = await MessageHelper.showConfirmDialog(
                    context: context,
                    title: 'Delete Habit',
                    message: 'Are you sure you want to delete "${habit.name}"? All progress will be lost.',
                  );

                  if (confirmed) {
                    try {
                      await _habitService.deleteHabit(habit.id);
                      if (mounted) {
                        MessageHelper.showSuccess(context, 'Habit deleted');
                      }
                    } catch (e) {
                      if (mounted) {
                        MessageHelper.showError(context, 'Failed to delete: $e');
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Habits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Stream all habits for the current user
          StreamBuilder<List<Habit>>(
            stream: _habitService.getHabits(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final habits = snapshot.data!;
              if (habits.isEmpty) {
                return SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Build your routine by adding a habit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }

              // Listen to habit logs for the selected day
              return StreamBuilder<List<HabitLog>>(
                stream: _habitLogService.getLogsForDay(widget.selectedDay),
                builder: (context, logSnap) {
                  final logs = logSnap.data ?? [];

                  // Filter only active habits
                  final activeHabits = habits.where((habit) {
                    return HabitUtils.isHabitActiveOnDay(
                        habit, widget.selectedDay);
                  }).toList();

                  // If there are no active habits for the selected day
                  if (activeHabits.isEmpty) {
                    return SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'No habits scheduled for today',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: activeHabits.map((habit) {
                        // Find the existing log for this habit (if any)
                        final log = logs.firstWhere(
                          (l) => l.habitId == habit.id,
                          orElse: () => HabitLog(
                            id: '',
                            habitId: habit.id,
                            userId: '',
                            dayKey: '',
                            done: false,
                          ),
                        );

                        // Display active habits
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
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
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                log.done
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: log.done
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              // Toggle completion state for this habit
                              onPressed: () async {
                                try {
                                  await _habitLogService.toggleHabit(
                                    habit.id,
                                    widget.selectedDay,
                                    log.done,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    MessageHelper.showError(
                                        context, 'Failed to update: $e');
                                  }
                                }
                              },
                            ),
                            title: Text(
                              habit.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onPressed: () => _showHabitOptions(habit),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}