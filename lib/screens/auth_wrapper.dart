import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/bottom_nav.dart';
import '../main.dart'; // import navigatorKey
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
            // Use navigatorKey to push BottomNav as root
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => const BottomNav()),
              );
            });
            return const SizedBox(); // placeholder while redirecting
          } else {
            // Use navigatorKey to push VerifyEmailScreen as root
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
              );
            });
            return const SizedBox(); // placeholder while redirecting
          }
        }

        // If no user is logged in, go to the login screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        });
        return const SizedBox(); // placeholder while redirecting
      },
    );
  }
}
