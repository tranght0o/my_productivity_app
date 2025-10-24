import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  // Ensure Flutter widgets are properly initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the platform-specific configuration
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Productivity App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      // AuthWrapper automatically decides which screen to show
      home: const AuthWrapper(),
    );
  }
}
