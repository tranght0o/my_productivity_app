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
  late TextEditingController _nameController;
  final _habitService = HabitService();

  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedDays = [];

  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habitToEdit?.name ?? '');
    if (widget.habitToEdit != null) {
      _startDate = widget.habitToEdit!.startDate;
      _endDate = widget.habitToEdit!.endDate;
      _selectedDays = List.from(widget.habitToEdit!.daysOfWeek);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // pick date from date picker
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart ? (_startDate ?? now) : (_endDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // save habit to Firestore
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _startDate == null || _selectedDays.isEmpty) return;

    if (widget.habitToEdit != null) {
      await _habitService.updateHabit(
        id: widget.habitToEdit!.id,
        name: name,
        startDate: _startDate,
        endDate: _endDate,
        daysOfWeek: _selectedDays,
      );
    } else {
      await _habitService.addHabit(
        name: name,
        startDate: _startDate!,
        endDate: _endDate,
        daysOfWeek: _selectedDays,
      );
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? 'Edit Habit' : 'Add Habit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // habit name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // start and end date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _pickDate(isStart: true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _startDate == null
                        ? 'Start date'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _pickDate(isStart: false),
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _endDate == null
                        ? 'End date (optional)'
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // select days of week
            Wrap(
              spacing: 6,
              children: [
                ChoiceChip(
                  label: const Text('Everyday'),
                  selected: _selectedDays.length == 7,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays = List.from(_daysOfWeek);
                      } else {
                        _selectedDays.clear();
                      }
                    });
                  },
                ),
                ..._daysOfWeek.map((day) {
                  return ChoiceChip(
                    label: Text(day),
                    selected: _selectedDays.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),

            // save button
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
