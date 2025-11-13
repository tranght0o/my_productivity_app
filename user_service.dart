import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// UserService handles fetching and updating user data from Firestore.
class UserService {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  /// Fetch a single user by uid
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);
    } catch (e) {
      // You can log error here if needed
      return null;
    }
  }

  /// Stream user data for realtime updates
  Stream<AppUser?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);
    });
  }

  /// Update user fields
  /// Only pass fields that need to be updated
  Future<void> updateUser(String uid, {String? name, String? photoUrl}) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    if (data.isEmpty) return; // nothing to update

    await _usersRef.doc(uid).update(data);
  }
}
