import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final DateTime date;
  bool done;

  Todo({
    required this.id,
    required this.title,
    required this.date,
    required this.done,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> data) {
    return Todo(
      id: id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      done: data['done'] ?? false,
    );
  }

  Map<String, dynamic> toMap(String uid) {
    return {
      'uid': uid,
      'title': title,
      'date': DateTime(date.year, date.month, date.day),
      'done': done,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
