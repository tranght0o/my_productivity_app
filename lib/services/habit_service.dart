import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

class HabitService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  // get all habits that belong to current user
  Stream<List<Habit>> getHabits() {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => Habit.fromMap(d.data(), d.id)).toList());
  }

  // add new habit with start/end date and days of week
  Future<void> addHabit({
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    required List<String> daysOfWeek,
  }) async {
    await _firestore.collection('habits').add({
      'userId': _user!.uid,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'daysOfWeek': daysOfWeek,
      'createdAt': DateTime.now(),
    });
  }

  // delete a habit by id
  Future<void> deleteHabit(String id) async {
    await _firestore.collection('habits').doc(id).delete();
  }

  // update habit name or info
  Future<void> updateHabit({
    required String id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? daysOfWeek,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (startDate != null) updateData['startDate'] = startDate;
    if (endDate != null) updateData['endDate'] = endDate;
    if (daysOfWeek != null) updateData['daysOfWeek'] = daysOfWeek;

    if (updateData.isNotEmpty) {
      await _firestore.collection('habits').doc(id).update(updateData);
    }
  }
}
