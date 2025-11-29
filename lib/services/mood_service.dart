import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_model.dart';

class MoodService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  /// Normalize a DateTime to only keep the date (no time).
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get a stream of the mood for a specific day.
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
  Future<void> addOrUpdateMood(DateTime date, int value) async {
    final normalizedDate = _normalizeDate(date);
    final moodsRef = _firestore.collection('moods');

    try {
      final existing = await moodsRef
          .where('userId', isEqualTo: _user!.uid)
          .where('date', isEqualTo: normalizedDate)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await moodsRef.add({
          'userId': _user.uid,
          'date': normalizedDate,
          'moodValue': value,
        });
      } else {
        await moodsRef.doc(existing.docs.first.id).update({
          'moodValue': value,
        });
      }
    } catch (e) {
      throw Exception('Failed to save mood: $e');
    }
  }

  /// Stream all moods of the current user (auto-updates in real time).
  Stream<List<Mood>> getAllMoods() {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map(
            (snapshot) => snapshot.docs.map((d) => Mood.fromMap(d.data(), d.id)).toList());
  }

  // ADDED: Query moods by specific month (for Library screen performance)
  Future<List<Mood>> getMoodsByMonth(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0);

      final snapshot = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: _user!.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      return snapshot.docs
          .map((doc) => Mood.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch moods by month: $e');
    }
  }

  // Limit data fetch for insights (not all time)
  Future<List<Mood>> getMoodsBetween(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: _user!.uid)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return snapshot.docs
          .map((doc) => Mood.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch moods: $e');
    }
  }

  //Use getMoodsByMonth or getMoodsBetween instead
  Future<List<Mood>> getAllMoodsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: _user!.uid)
          .get();

      return snapshot.docs
          .map((doc) => Mood.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all moods: $e');
    }
  }
  /// Stream moods by month (real-time updates)
  Stream<List<Mood>> getMoodsByMonthStream(int year, int month) {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0);

      return _firestore
          .collection('moods')
          .where('userId', isEqualTo: _user!.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Mood.fromMap(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to stream moods by month: $e');
    }
  }

}
