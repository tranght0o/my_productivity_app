import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> addTodo({required String title, required DateTime date}) async {
    if (uid == null) return;
    await _firestore.collection('todos').add({
      'uid': uid,
      'title': title,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Todo>> getTodosForDay(DateTime day) {
    if (uid == null) return const Stream.empty();
    final start = DateTime(day.year, day.month, day.day);

    return _firestore
        .collection('todos')
        .where('uid', isEqualTo: uid)
        .where('date', isEqualTo: start)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Todo.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> toggleDone(String id, bool done) async {
    await _firestore.collection('todos').doc(id).update({'done': !done});
  }
}
