import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../../models/habit_model.dart';

class AddHabitBottomSheet extends StatefulWidget {
  final Habit? habitToEdit;
  const AddHabitBottomSheet({super.key, this.habitToEdit});

  @override
  State<AddHabitBottomSheet> createState() => _AddHabitBottomSheetState();
}

class _AddHabitBottomSheetState extends State<AddHabitBottomSheet> {
  late TextEditingController _controller;
  final _habitService = HabitService();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.habitToEdit?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    if (widget.habitToEdit != null) {
      await _habitService.updateHabit(widget.habitToEdit!.id, name);
    } else {
      await _habitService.addHabit(name);
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habitToEdit != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? 'Edit Habit' : 'Add Habit',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _save,
            child: Text(isEdit ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }
}
