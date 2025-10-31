import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_log_model.dart';

class HabitLogService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  String _dayKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  Stream<List<HabitLog>> getLogsForDay(DateTime date) {
    return _firestore
        .collection('habitLogs')
        .where('userId', isEqualTo: _user!.uid)
        .where('dayKey', isEqualTo: _dayKey(date))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => HabitLog.fromMap(d.data(), d.id)).toList());
  }

  Future<void> toggleHabit(String habitId, DateTime date, bool currentState) async {
    final dayKey = _dayKey(date);
    final ref = _firestore.collection('habitLogs');
    final query = await ref
        .where('userId', isEqualTo: _user!.uid)
        .where('habitId', isEqualTo: habitId)
        .where('dayKey', isEqualTo: dayKey)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      await ref.add({
        'userId': _user.uid,
        'habitId': habitId,
        'dayKey': dayKey,
        'done': true,
      });
    } else {
      await ref.doc(query.docs.first.id).update({'done': !currentState});
    }
  }

  Future<List<HabitLog>> getLogsBetween(DateTime start, DateTime end) async {
    final query = await _firestore
        .collection('habitLogs')
        .where('userId', isEqualTo: _user!.uid)
        .get();

    final all = query.docs.map((d) => HabitLog.fromMap(d.data(), d.id)).toList();

    return all.where((l) {
      final parts = l.dayKey.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

}
