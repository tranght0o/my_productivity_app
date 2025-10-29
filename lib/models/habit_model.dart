import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate; // when the habit starts
  final DateTime? endDate; // when the habit ends (can be null)
  final List<String> daysOfWeek; // which days in a week this habit repeats
  final DateTime createdAt; // when it was created

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.createdAt,
  });

  // convert data from firestore to Habit object
  factory Habit.fromMap(Map<String, dynamic> data, String id) {
    return Habit(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      daysOfWeek: List<String>.from(data['daysOfWeek'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // convert Habit object to map for firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'daysOfWeek': daysOfWeek,
      'createdAt': createdAt,
    };
  }
}
