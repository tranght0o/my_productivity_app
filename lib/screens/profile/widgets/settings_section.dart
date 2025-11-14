import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth_wrapper.dart';
import '../my_account_screen.dart'; // Import MyAccountScreen

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  // Handles user sign-out and navigation back to AuthWrapper
  Future<void> _logout(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Make sure the widget is still mounted before navigation
      if (!context.mounted) return;

      // Clear all previous routes and navigate to AuthWrapper
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully.')),
      );
    } catch (e) {
      // Handle sign-out error
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Account settings
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: Colors.deepPurple),
            title: const Text("My Account"),
            subtitle: const Text("Manage your account settings"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyAccountScreen()),
              );
            },
          ),
          const Divider(height: 1),

          // Notification toggle
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none, color: Colors.deepPurple),
            title: const Text("Notifications"),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(height: 1),

          // App theme option
          ListTile(
            leading: const Icon(Icons.color_lens_outlined, color: Colors.deepPurple),
            title: const Text("App Theme"),
            subtitle: const Text("Choose light or dark mode"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),

          // Logout option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Log out"),
            subtitle: const Text("Sign out from your account"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
