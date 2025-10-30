import 'package:cloud_firestore/cloud_firestore.dart';

class Mood {
  final String id; // mood id in firestore
  final String userId; // which user
  final DateTime date; // which day this mood is for
  final int moodValue; // mood level
  final String? note; // optional note text

  Mood({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodValue,
    this.note,
  });

  // convert firestore data to Mood
  factory Mood.fromMap(Map<String, dynamic> data, String id) {
    return Mood(
      id: id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      moodValue: data['moodValue'] ?? 0,
      note: data['note'],
    );
  }

  // convert Mood to firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'moodValue': moodValue,
      'note': note,
    };
  }
}
