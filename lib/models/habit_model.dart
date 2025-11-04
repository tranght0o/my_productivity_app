import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> daysOfWeek;
  final List<int> daysOfMonth;
  final String frequency; // "daily", "weekly", or "monthly"
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.daysOfMonth,
    required this.frequency,
    required this.createdAt,
  });

  /// Convert a Firestore document into a Habit object.
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
      daysOfMonth: List<int>.from(data['daysOfMonth'] ?? []),
      frequency: data['frequency'] ?? 'daily',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert a Habit object back into a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'daysOfWeek': daysOfWeek,
      'daysOfMonth': daysOfMonth,
      'frequency': frequency,
      'createdAt': createdAt,
    };
  }
}