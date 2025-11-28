import 'package:flutter/material.dart';

class MessageHelper {
  // Brand Colors (primary + accent)
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Color(0xFFfab0c4);

  // Base builder for all SnackBars
  static SnackBar _buildSnackBar({
    required Widget content,
    Color? background,
  }) {
    return SnackBar(
      content: content,
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      backgroundColor: background ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Shared layout for icon + message text inside SnackBars
  static Widget _buildContent({
    required IconData icon,
    required String message,
    required Color iconColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        content: _buildContent(
          icon: Icons.check_circle,
          message: message,
          iconColor: primaryColor,
          textColor: Colors.black87,
        ),
      ),
    );
  }

  /// Show error message
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        background: secondaryColor.withOpacity(0.22),
        content: _buildContent(
          icon: Icons.error_outline,
          message: message,
          iconColor: secondaryColor,
          textColor: Colors.black87,
        ),
      ),
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        background: secondaryColor.withOpacity(0.18),
        content: _buildContent(
          icon: Icons.warning_amber_rounded,
          message: message,
          iconColor: secondaryColor.withOpacity(0.9),
          textColor: Colors.black87,
        ),
      ),
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildContent(
          icon: Icons.info_outline,
          message: message,
          iconColor: primaryColor,
          textColor: Colors.black87,
        ),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryColor.withOpacity(0.4), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show a confirm dialog
  /// Returns: true if user confirms, false otherwise
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: const Icon(Icons.close, color: Colors.black54),
            )
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: Text(
              cancelText,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),

          // Confirm button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
