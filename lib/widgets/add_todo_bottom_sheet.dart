import 'package:flutter/material.dart';
import '../services/todo_service.dart';
import '../models/todo_model.dart';

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
  final _service = TodoService();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.todoToEdit?.date ?? widget.initialDate;
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.todoToEdit != null) {
      // update
      await _service.updateTodo(
        id: widget.todoToEdit!.id,
        title: title,
        date: _selectedDate,
      );
    } else {
      // add new
      await _service.addTodo(
        title: title,
        date: _selectedDate,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_selectedDate.toLocal()}".split(' ')[0]),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: const Text('Change date'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _save,
            child: Text(widget.todoToEdit != null ? 'Update' : 'Add'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
