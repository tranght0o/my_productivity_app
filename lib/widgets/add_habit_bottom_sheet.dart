import 'package:flutter/material.dart';
import '../services/habit_service.dart';
import '../models/habit_model.dart';
import '../utils/message_helper.dart';

/// Bottom sheet for adding or editing a habit
/// Now supports daily / weekly / monthly frequencies with validation
class AddHabitBottomSheet extends StatefulWidget {
  final Habit? habitToEdit;
  const AddHabitBottomSheet({super.key, this.habitToEdit});

  @override
  State<AddHabitBottomSheet> createState() => _AddHabitBottomSheetState();
}

class _AddHabitBottomSheetState extends State<AddHabitBottomSheet> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  final _habitService = HabitService();

  DateTime? _startDate;
  DateTime? _endDate;
  String _frequency = 'daily';
  List<String> _selectedDaysOfWeek = [];
  List<int> _selectedDaysOfMonth = [];
  bool _loading = false;

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

  /// Validate form before saving
  String? _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return 'Please enter a habit name';
    }
    if (_startDate == null) {
      return 'Please select a start date';
    }
    if (_frequency == 'weekly' && _selectedDaysOfWeek.isEmpty) {
      return 'Please select at least one day for weekly habit';
    }
    if (_frequency == 'monthly' && _selectedDaysOfMonth.isEmpty) {
      return 'Please select at least one day for monthly habit';
    }
    return null;
  }

  /// Save or update the habit
  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      MessageHelper.showWarning(context, error);
      return;
    }

    setState(() => _loading = true);

    try {
      final name = _nameController.text.trim();
      
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
        if (mounted) {
          Navigator.pop(context);
          MessageHelper.showSuccess(context, 'Habit updated successfully!');
        }
      } else {
        await _habitService.addHabit(
          name: name,
          startDate: _startDate!,
          endDate: _endDate,
          frequency: _frequency,
          daysOfWeek: _frequency == 'weekly' ? _selectedDaysOfWeek : [],
          daysOfMonth: _frequency == 'monthly' ? _selectedDaysOfMonth : [],
        );
        if (mounted) {
          Navigator.pop(context);
          MessageHelper.showSuccess(context, 'Habit created successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        MessageHelper.showError(context, 'Failed to save habit: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Edit Habit' : 'Add Habit',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Habit name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.fitness_center),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: true),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _startDate == null
                              ? 'Start date'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        icon: const Icon(Icons.event, size: 18),
                        label: Text(
                          _endDate == null
                              ? 'End (optional)'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _frequency,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.repeat),
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

                if (_frequency == 'weekly') ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select days:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: _daysOfWeek.map((day) {
                      return ChoiceChip(
                        label: Text(day),
                        selected: _selectedDaysOfWeek.contains(day),
                        selectedColor: Colors.deepPurple.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                  ),
                  const SizedBox(height: 8),
                ],

                if (_frequency == 'monthly') ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select days of month:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: List.generate(31, (i) {
                      final day = i + 1;
                      final selected = _selectedDaysOfMonth.contains(day);
                      return ChoiceChip(
                        label: Text(day.toString()),
                        selected: selected,
                        selectedColor: Colors.deepPurple.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEdit ? 'Update' : 'Save',
                            style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
