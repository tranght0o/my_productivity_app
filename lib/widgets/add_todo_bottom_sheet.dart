import 'package:flutter/material.dart';
import '../services/todo_service.dart';

class AddTodoBottomSheet extends StatefulWidget {
  final DateTime initialDate;

  const AddTodoBottomSheet({super.key, required this.initialDate});

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
    _selectedDate = widget.initialDate;
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
            onPressed: () async {
              if (_titleController.text.trim().isEmpty) return;
              await _service.addTodo(
                title: _titleController.text.trim(),
                date: _selectedDate,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
