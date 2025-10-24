import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      case 'too-many-requests':
        return 'Too many requests. Try later';
      default:
        return 'Authentication error: $code';
    }
  }
}
