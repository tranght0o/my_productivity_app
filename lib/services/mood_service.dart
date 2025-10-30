import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_model.dart';

class MoodService {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  // get all moods of current user (ordered by date)
  Stream<List<Mood>> getMoods() {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: _user!.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => Mood.fromMap(d.data(), d.id)).toList());
  }

  // add new mood log
  Future<void> addMood(int moodValue, DateTime date, {String? note}) async {
    await _firestore.collection('moods').add({
      'userId': _user!.uid,
      'moodValue': moodValue,
      'date': date,
      'note': note ?? '',
      'createdAt': DateTime.now(),
    });
  }

  // update mood 
  Future<void> updateMood(String id, int moodValue, {String? note}) async {
    await _firestore.collection('moods').doc(id).update({
      'moodValue': moodValue,
      'note': note ?? '',
    });
  }

  // delete mood log
  Future<void> deleteMood(String id) async {
    await _firestore.collection('moods').doc(id).delete();
  }
}
