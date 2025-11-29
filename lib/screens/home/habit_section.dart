import 'package:flutter/material.dart';
import '../../services/habit_service.dart';
import '../../services/habit_log_service.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../../widgets/add_habit_bottom_sheet.dart';
import '../../utils/habit_utils.dart';
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
                    builder: (_) =>
                        AddHabitBottomSheet(habitToEdit: habit),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);

                  final confirmed = await MessageHelper.showConfirmDialog(
                    context: context,
                    title: 'Delete Habit',
                    message:
                        'Are you sure you want to delete "${habit.name}"? All progress will be lost.',
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
      color: const Color(0xFFF5F6FA),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Text(
              'Habits',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),

          StreamBuilder<List<Habit>>(
            stream: _habitService.getHabits(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final habits = snapshot.data!;
              if (habits.isEmpty) {
                return SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'Build your routine by adding a habit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }

              return StreamBuilder<List<HabitLog>>(
                stream: _habitLogService.getLogsForDay(widget.selectedDay),
                builder: (context, logSnap) {
                  final logs = logSnap.data ?? [];

                  final activeHabits = habits.where((habit) {
                    return HabitUtils.isHabitActiveOnDay(
                        habit, widget.selectedDay);
                  }).toList();

                  if (activeHabits.isEmpty) {
                    return SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          'No habits scheduled for today',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: activeHabits.map((habit) {
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

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 12,
                            leading: IconButton(
                              icon: Icon(
                                log.done
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: log.done
                                    ? Colors.deepPurple.shade400
                                    : Colors.grey.shade400,
                                size: 26,
                              ),
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
                                fontSize: 15,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey.shade500,
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
