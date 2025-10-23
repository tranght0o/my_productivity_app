import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../login_screen.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: Colors.deepPurple),
            title: const Text("My Account"),
            subtitle: const Text("Manage your account settings"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none, color: Colors.deepPurple),
            title: const Text("Notifications"),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined, color: Colors.deepPurple),
            title: const Text("App Theme"),
            subtitle: const Text("Choose light or dark mode"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
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
