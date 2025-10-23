import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({super.key});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _updateName() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update name: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Name"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: "Enter your new name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _updateName,
          child: _loading
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Save"),
        ),
      ],
    );
  }
}
