import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/more_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ProfileHeader(),
              SizedBox(height: 24),
              SettingsSection(),
              SizedBox(height: 24),
              MoreSection(),
            ],
          ),
        ),
      ),
    );
  }
}
