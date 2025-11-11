import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/bottom_nav.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to authentication state changes from Firebase
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for Firebase to respond
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If an error occurs while connecting to Firebase
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('An error occurred. Please try again.')),
          );
        }

        // If a user is logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Check if email is verified
          if (user.emailVerified) {
            return const BottomNav();
          } else {
            return const VerifyEmailScreen();
          }
        }

        // If no user is logged in, go to the login screen
        return const LoginScreen();
      },
    );
  }
}
