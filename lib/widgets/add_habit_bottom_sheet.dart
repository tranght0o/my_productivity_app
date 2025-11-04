import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../models/habit_model.dart';

/// Bottom sheet for adding or editing a habit
/// Now supports daily / weekly / monthly frequencies
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
  String _frequency = 'daily'; // default frequency
  List<String> _selectedDaysOfWeek = [];
  List<int> _selectedDaysOfMonth = [];

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
      final h = widget.habitToEdit!;
      _startDate = h.startDate;
      _endDate = h.endDate;
      _frequency = h.frequency;
      _selectedDaysOfWeek = List.from(h.daysOfWeek);
      _selectedDaysOfMonth = List.from(h.daysOfMonth);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Pick a date using Flutter's date picker
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

  /// Save or update the habit
  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _startDate == null) return;

    if (widget.habitToEdit != null) {
      await _habitService.updateHabit(
        id: widget.habitToEdit!.id,
        name: name,
        startDate: _startDate,
        endDate: _endDate,
        frequency: _frequency,
        daysOfWeek: _frequency == 'weekly' ? _selectedDaysOfWeek : [],
        daysOfMonth: _frequency == 'monthly' ? _selectedDaysOfMonth : [],
      );
    } else {
      await _habitService.addHabit(
        name: name,
        startDate: _startDate!,
        endDate: _endDate,
        frequency: _frequency,
        daysOfWeek: _frequency == 'weekly' ? _selectedDaysOfWeek : [],
        daysOfMonth: _frequency == 'monthly' ? _selectedDaysOfMonth : [],
      );
    }

    if (context.mounted) Navigator.pop(context);
  }

  /// UI to select days of the week (for weekly habits)
  Widget _buildWeeklySelector() {
    return Wrap(
      spacing: 6,
      children: _daysOfWeek.map((day) {
        return ChoiceChip(
          label: Text(day),
          selected: _selectedDaysOfWeek.contains(day),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDaysOfWeek.add(day);
              } else {
                _selectedDaysOfWeek.remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }

  /// UI to select days of the month (for monthly habits)
  Widget _buildMonthlySelector() {
    return Wrap(
      spacing: 6,
      children: List.generate(31, (i) {
        final day = i + 1;
        final selected = _selectedDaysOfMonth.contains(day);
        return ChoiceChip(
          label: Text(day.toString()),
          selected: selected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDaysOfMonth.add(day);
              } else {
                _selectedDaysOfMonth.remove(day);
              }
            });
          },
        );
      }),
    );
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
            // Title
            Text(
              isEdit ? 'Edit Habit' : 'Add Habit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Start & End date picker
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

            // Frequency selector
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (val) {
                setState(() => _frequency = val ?? 'daily');
              },
            ),
            const SizedBox(height: 12),

            // Conditional day selectors
            if (_frequency == 'weekly') _buildWeeklySelector(),
            if (_frequency == 'monthly') _buildMonthlySelector(),
            const SizedBox(height: 16),

            // Save button
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
