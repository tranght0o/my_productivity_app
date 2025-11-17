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
    try {
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
    } catch (e) {
      throw Exception('Failed to toggle habit: $e');
    }
  }

  // IMPROVED: More efficient query with proper date filtering
  Future<List<HabitLog>> getLogsBetween(DateTime start, DateTime end) async {
    try {
      // Generate all possible dayKeys in range for better query
      final List<String> dayKeys = [];
      for (var date = start; 
           date.isBefore(end) || date.isAtSameMomentAs(end); 
           date = date.add(const Duration(days: 1))) {
        dayKeys.add(_dayKey(date));
      }

      // If range is too large (>90 days), use old method
      if (dayKeys.length > 90) {
        return _getLogsLegacy(start, end);
      }

      // Query with dayKey filter (more efficient)
      final snapshot = await _firestore
          .collection('habitLogs')
          .where('userId', isEqualTo: _user!.uid)
          .where('dayKey', whereIn: dayKeys.take(10).toList()) // Firestore limit: 10 items
          .get();

      // For larger ranges, make multiple queries
      List<HabitLog> allLogs = [];
      for (var i = 0; i < dayKeys.length; i += 10) {
        final batch = dayKeys.skip(i).take(10).toList();
        final batchSnapshot = await _firestore
            .collection('habitLogs')
            .where('userId', isEqualTo: _user!.uid)
            .where('dayKey', whereIn: batch)
            .get();
        
        allLogs.addAll(
          batchSnapshot.docs.map((d) => HabitLog.fromMap(d.data(), d.id))
        );
      }

      return allLogs;
    } catch (e) {
      throw Exception('Failed to fetch habit logs: $e');
    }
  }

  // ADDED: Get logs for specific month (for Library screen)
  Future<List<HabitLog>> getLogsByMonth(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0);
      
      return getLogsBetween(startOfMonth, endOfMonth);
    } catch (e) {
      throw Exception('Failed to fetch logs by month: $e');
    }
  }

  // Legacy method: fetch all and filter client-side (fallback)
  Future<List<HabitLog>> _getLogsLegacy(DateTime start, DateTime end) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to fetch habit logs (legacy): $e');
    }
  }
}