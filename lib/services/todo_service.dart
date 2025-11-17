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

  // ADDED: Query todos by specific month (for Library screen performance)
  Future<List<Todo>> getTodosByMonth(int year, int month) async {
    if (uid == null) return [];
    
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch todos by month: $e');
    }
  }

  // IMPROVED: Limit data fetch for insights (not all time)
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

  // DEPRECATED: Use getTodosByMonth or getTodosBetween instead
  @Deprecated('Use getTodosByMonth() for better performance')
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
}