import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

/// Service for interacting with the Firestore "habits" collection
class HabitService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  /// Stream all habits belonging to the current user
  Stream<List<Habit>> getHabits() {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => Habit.fromMap(d.data(), d.id)).toList());
  }

  /// Add a new habit with frequency type and repeat pattern
  Future<void> addHabit({
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    required String frequency, // daily / weekly / monthly
    List<String>? daysOfWeek, // for weekly
    List<int>? daysOfMonth, // for monthly
  }) async {
    await _firestore.collection('habits').add({
      'userId': _user!.uid,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'frequency': frequency,
      'daysOfWeek': daysOfWeek ?? [],
      'daysOfMonth': daysOfMonth ?? [],
      'createdAt': DateTime.now(),
    });
  }

  /// Delete a habit by its Firestore document ID
  Future<void> deleteHabit(String id) async {
    await _firestore.collection('habits').doc(id).delete();
  }

  /// Update habit details (supports partial updates)
  Future<void> updateHabit({
    required String id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? frequency,
    List<String>? daysOfWeek,
    List<int>? daysOfMonth,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (startDate != null) updateData['startDate'] = startDate;
    if (endDate != null) updateData['endDate'] = endDate;
    if (frequency != null) updateData['frequency'] = frequency;
    if (daysOfWeek != null) updateData['daysOfWeek'] = daysOfWeek;
    if (daysOfMonth != null) updateData['daysOfMonth'] = daysOfMonth;

    if (updateData.isNotEmpty) {
      await _firestore.collection('habits').doc(id).update(updateData);
    }
  }
}
