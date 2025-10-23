class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final String dayKey;
  final bool done;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.dayKey,
    required this.done,
  });

  factory HabitLog.fromMap(Map<String, dynamic> data, String id) {
    return HabitLog(
      id: id,
      habitId: data['habitId'] ?? '',
      userId: data['userId'] ?? '',
      dayKey: data['dayKey'] ?? '',
      done: data['done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'userId': userId,
      'dayKey': dayKey,
      'done': done,
    };
  }
}
