import 'package:flutter/material.dart';

class AboutAppDialog {
  static Future<void> show(BuildContext context) async {
    //App info
    String version = "1.0.0";
    String buildNumber = "1";

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes,
                size: 40,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'My Productivity App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Version $version ($buildNumber)',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your daily tasks, build lasting habits, and monitor your mood all in one beautiful app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.person, 'Developer', 'Your Name'),
            _buildInfoRow(Icons.code, 'Built with', 'Flutter & Firebase'),
            _buildInfoRow(Icons.calendar_today, 'Released', '2024'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Features:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeature('📝 Smart task management'),
            _buildFeature('🎯 Flexible habit tracking'),
            _buildFeature('😊 Daily mood journaling'),
            _buildFeature('📊 Insightful analytics'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              showLicensePage(
                context: context,
                applicationName: 'My Productivity App',
                applicationVersion: version,
                applicationIcon: Icon(
                  Icons.track_changes,
                  size: 48,
                  color: Colors.deepPurple.shade700,
                ),
              );
            },
            child: const Text('View Licenses'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 8),
      child: Text(
        feature,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
