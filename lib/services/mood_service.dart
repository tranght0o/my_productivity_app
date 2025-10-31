import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_model.dart';

class MoodService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  /// Helper to generate a consistent key for each day (e.g. 2025-10-25)
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get a stream of the mood for a specific day (used by the UI)
  Stream<Mood?> getMoodForDay(DateTime date) {
    final dayKey = _getDayKey(date);
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .where('dayKey', isEqualTo: dayKey)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Mood.fromMap(doc.data(), doc.id);
    });
  }

  /// Add a new mood or update an existing one for the selected day
  Future<void> addOrUpdateMood(DateTime date, int value, String? note) async {
    final dayKey = _getDayKey(date);
    final moodsRef = _firestore.collection('moods');

    // Check if a mood already exists for this user/day
    final existing = await moodsRef
        .where('userId', isEqualTo: _user!.uid)
        .where('dayKey', isEqualTo: dayKey)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      // Create new
      await moodsRef.add({
        'userId': _user.uid,
        'moodValue': value,
        'note': note,
        'dayKey': dayKey,
        'createdAt': DateTime.now(),
      });
    } else {
      // Update existing
      await moodsRef.doc(existing.docs.first.id).update({
        'moodValue': value,
        'note': note,
      });
    }
  }

  /// Stream all moods (for live tracking)
  Stream<List<Mood>> getAllMoods() {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => Mood.fromMap(d.data(), d.id)).toList());
  }

  /// Fetch all moods once (used for calendar)
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
