import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory Habit.fromMap(Map<String, dynamic> data, String id) {
    return Habit(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'createdAt': createdAt,
    };
  }
}
