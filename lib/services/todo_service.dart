import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> addTodo({required String title, required DateTime date}) async {
    if (uid == null) return;
    try {
      await _firestore.collection('todos').add({
        'uid': uid,
        'title': title,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'done': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    required DateTime date,
  }) async {
    try {
      await _firestore.collection('todos').doc(id).update({
        'title': title,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      });
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _firestore.collection('todos').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
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
    try {
      await _firestore.collection('todos').doc(id).update({'done': !done});
    } catch (e) {
      throw Exception('Failed to toggle todo: $e');
    }
  }

  Future<List<Todo>> getTodosBetween(DateTime start, DateTime end) async {
    if (uid == null) return [];
    
    try {
      final snapshot = await _firestore
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }


  Future<List<Todo>> getAllTodosOnce() async {
    if (uid == null) return [];
    try {
      final snapshot = await _firestore
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .get();
      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all todos: $e');
    }
  }

  Stream<List<Todo>> getTodosByMonthStream(int year, int month) {
  if (uid == null) return const Stream.empty();

  final startOfMonth = DateTime(year, month, 1);
  final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

  return _firestore
      .collection('todos')
      .where('uid', isEqualTo: uid)
      .where('date', isGreaterThanOrEqualTo: startOfMonth)
      .where('date', isLessThanOrEqualTo: endOfMonth)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Todo.fromMap(doc.id, doc.data()))
            .toList(),
      );
}

}