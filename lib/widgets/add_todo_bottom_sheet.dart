import 'package:flutter/material.dart';
import '../services/todo_service.dart';
import '../models/todo_model.dart';
import '../utils/message_helper.dart';

class AddTodoBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final Todo? todoToEdit;

  const AddTodoBottomSheet({
    super.key,
    required this.initialDate,
    this.todoToEdit,
  });

  @override
  State<AddTodoBottomSheet> createState() => _AddTodoBottomSheetState();
}

class _AddTodoBottomSheetState extends State<AddTodoBottomSheet> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _service = TodoService();
  late DateTime _selectedDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.todoToEdit?.date ?? widget.initialDate;
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();

    setState(() => _loading = true);

    try {
      if (widget.todoToEdit != null) {
        // Update existing todo
        await _service.updateTodo(
          id: widget.todoToEdit!.id,
          title: title,
          date: _selectedDate,
        );
        if (mounted) {
          Navigator.pop(context);
          MessageHelper.showSuccess(context, 'Task updated successfully!');
        }
      } else {
        // Add new todo
        await _service.addTodo(
          title: title,
          date: _selectedDate,
        );
        if (mounted) {
          Navigator.pop(context);
          MessageHelper.showSuccess(context, 'Task added successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        MessageHelper.showError(context, 'Failed to save task: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todoToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
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
                isEdit ? 'Edit Task' : 'Add Task',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Change date'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
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
                      : Text(isEdit ? 'Update' : 'Add',
                          style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
