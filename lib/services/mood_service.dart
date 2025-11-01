import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_model.dart';

class MoodService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  /// Normalize a DateTime to only keep the date (no time).
  /// Example: 2025-10-31 10:45 → becomes 2025-10-31 00:00.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get a stream of the mood for a specific day.
  /// This updates in real time when Firestore data changes.
  Stream<Mood?> getMoodForDay(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .where('date', isEqualTo: normalizedDate)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Mood.fromMap(doc.data(), doc.id);
    });
  }

  /// Add a new mood or update an existing one for the selected day.
  /// If a record for that date already exists, it is updated instead of duplicated.
  Future<void> addOrUpdateMood(DateTime date, int value, String? note) async {
    final normalizedDate = _normalizeDate(date);
    final moodsRef = _firestore.collection('moods');

    // Check if a mood already exists for this user and date.
    final existing = await moodsRef
        .where('userId', isEqualTo: _user!.uid)
        .where('date', isEqualTo: normalizedDate)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      // Create a new mood document
      await moodsRef.add({
        'userId': _user.uid,
        'date': normalizedDate,
        'moodValue': value,
        'note': note,
      });
    } else {
      // Update the existing mood document
      await moodsRef.doc(existing.docs.first.id).update({
        'moodValue': value,
        'note': note,
      });
    }
  }

  /// Stream all moods of the current user (auto-updates in real time).
  Stream<List<Mood>> getAllMoods() {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => Mood.fromMap(d.data(), d.id)).toList());
  }

  /// Fetch all moods once (used for calendar and reports).
  Future<List<Mood>> getAllMoodsOnce() async {
    final snapshot = await _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .get();

    return snapshot.docs
        .map((doc) => Mood.fromMap(doc.data(), doc.id))
        .toList();
  }
}
