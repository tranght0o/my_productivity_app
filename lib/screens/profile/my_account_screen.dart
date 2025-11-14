import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_wrapper.dart';

/// Screen that lets the user manage sensitive account settings
/// - View their email
/// - Change password via AuthService
/// - Delete their account via AuthService
class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Change password using AuthService
  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showMessage('Please fill in both fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final error = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (error != null) {
        _showMessage(error);
      } else {
        _showMessage('Password updated successfully.');
        _currentPasswordController.clear();
        _newPasswordController.clear();
      }
    } catch (_) {
      _showMessage('Unexpected error occurred.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Delete account using AuthService
  Future<void> _deleteAccount() async {
    final currentPasswordController = TextEditingController();
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      _showMessage('No user logged in.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm deletion:'),
            const SizedBox(height: 8),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final error = await _authService.deleteAccount(
        currentPassword: currentPasswordController.text.trim(),
      );

      if (error != null) {
        _showMessage(error);
      } else {
        _showMessage('Account deleted successfully.');
        if (!mounted) return;
        await _authService.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseAuth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display email
                  Text('Email', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(user?.email ?? 'Unknown', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const Divider(height: 32),

                  // Change password section
                  Text('Change Password', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                      child: const Text('Update Password'),
                    ),
                  ),
                  const Divider(height: 40),

                  // Delete account section
                  Text('Danger Zone', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _deleteAccount,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete Account'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
