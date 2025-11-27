import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../navigation/bottom_nav.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _name = '';
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _errorMessage;

  // Validate name input
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name cannot be empty';
    return null;
  }

  // Validate email input
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email cannot be empty';
    if (!value.contains('@')) return 'Invalid email';
    return null;
  }

  // Validate password input
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Handle user signup logic
  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    _formKey.currentState!.save();

    // Attempt to create account through AuthService
    final error = await _authService.signUp(
      name: _name,
      email: _email,
      password: _password,
    );

    setState(() => _loading = false);

    // If there's an error (e.g., email already in use)
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Navigate to home screen after successful signup
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNav()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient for visual appeal
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and subtitle
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join us today!',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Display error message if signup fails
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Name input field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: _validateName,
                        onSaved: (val) => _name = val!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Email input field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        onSaved: (val) => _email = val!.trim(),
                      ),
                      const SizedBox(height: 12),

                      // Password input field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                        validator: _validatePassword,
                        onSaved: (val) => _password = val!.trim(),
                      ),
                      const SizedBox(height: 24),

                      // Signup button (shows loading spinner while creating account)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading ? null : _signup,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login redirect
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("Already have an account? Sign in"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}