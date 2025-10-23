import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

class HabitService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  Stream<List<Habit>> getHabits() {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => Habit.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addHabit(String name) async {
    await _firestore.collection('habits').add({
      'userId': _user!.uid,
      'name': name,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> deleteHabit(String id) async {
    await _firestore.collection('habits').doc(id).delete();
  }

  Future<void> updateHabit(String id, String name) async {
    await _firestore.collection('habits').doc(id).update({'name': name});
  }
}
