import 'package:flutter/material.dart';
import '../../services/habit_service.dart';
import '../../services/habit_log_service.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';

class HabitSection extends StatefulWidget {
  final DateTime selectedDay;
  const HabitSection({super.key, required this.selectedDay});

  @override
  State<HabitSection> createState() => _HabitSectionState();
}

class _HabitSectionState extends State<HabitSection> {
  final _habitService = HabitService();
  final _habitLogService = HabitLogService();

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
          StreamBuilder<List<Habit>>(
            stream: _habitService.getHabits(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final habits = snapshot.data!;
              if (habits.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No habits yet'),
                );
              }

              return StreamBuilder<List<HabitLog>>(
                stream: _habitLogService.getLogsForDay(widget.selectedDay),
                builder: (context, logSnap) {
                  final logs = logSnap.data ?? [];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: habits.map((habit) {
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
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () => _habitLogService.toggleHabit(
                                habit.id,
                                widget.selectedDay,
                                log.done,
                              ),
                            ),
                            title: Text(
                              habit.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
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
