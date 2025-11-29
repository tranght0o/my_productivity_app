import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current logged-in user
  User? get currentUser => _auth.currentUser;

  // Stream that listens for changes in authentication state
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Sign up a new user with name, email, and password
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name (user's name)
      await cred.user?.updateDisplayName(name);

      // Create AppUser object
      final newUser = AppUser(
        uid: cred.user!.uid,
        name: name,
        email: email,
        photoUrl: '', // default empty, can update later
        createdAt: DateTime.now(),
      );

      // Save user info to Firestore
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      // Return null if success (no error message)
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific error codes
      return _mapError(e.code);
    } catch (_) {
      // Handle unexpected errors
      return 'Unexpected error';
    }
  }

  // Sign in an existing user with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Unexpected error';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    } catch (_) {
      throw Exception('Unexpected error sending password reset email');
    }
  }

  // Change password after re-authenticating
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return 'No authenticated user found.';
      }

      // Re-authenticate before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Unexpected error changing password';
    }
  }

  // Delete user account and all associated data
  Future<String?> deleteAccount({
    required String currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return 'No authenticated user found.';
      }

      // Re-authenticate before deleting
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;

      // Delete all user data from Firestore
      await _deleteAllUserData(uid);

      // Delete user profile from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete from Firebase Authentication
      await user.delete();

      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Unexpected error deleting account';
    }
  }

  // Delete all user data from Firestore collections
  Future<void> _deleteAllUserData(String uid) async {
    try {
      // Use batch for efficient deletion
      final batch = _firestore.batch();
      int batchCount = 0;
      const batchLimit = 500; // Firestore batch limit

      // Delete all habits
      final habitsQuery = await _firestore
          .collection('habits')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in habitsQuery.docs) {
        batch.delete(doc.reference);
        batchCount++;

        if (batchCount >= batchLimit) {
          await batch.commit();
          batchCount = 0;
        }
      }

      // Delete all habit logs
      final logsQuery = await _firestore
          .collection('habitLogs')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in logsQuery.docs) {
        batch.delete(doc.reference);
        batchCount++;

        if (batchCount >= batchLimit) {
          await batch.commit();
          batchCount = 0;
        }
      }

      // Delete all todos
      final todosQuery = await _firestore
          .collection('todos')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in todosQuery.docs) {
        batch.delete(doc.reference);
        batchCount++;

        if (batchCount >= batchLimit) {
          await batch.commit();
          batchCount = 0;
        }
      }

      // Delete all moods (if you have a moods collection)
      final moodsQuery = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in moodsQuery.docs) {
        batch.delete(doc.reference);
        batchCount++;

        if (batchCount >= batchLimit) {
          await batch.commit();
          batchCount = 0;
        }
      }

      // Commit remaining batch operations
      if (batchCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Map Firebase error codes to readable messages
  String _mapError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      case 'user-disabled':
        return 'User disabled';
      case 'weak-password':
        return 'Weak password';
      case 'requires-recent-login':
        return 'Please reauthenticate before performing this action.';
      case 'too-many-requests':
        return 'Too many requests. Try later';
      default:
        return 'Authentication error: $code';
    }
  }
}