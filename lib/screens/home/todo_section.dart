import 'package:flutter/material.dart';
import '../../services/todo_service.dart';
import '../../models/todo_model.dart';
import '../../widgets/add_todo_bottom_sheet.dart';
import '../../utils/message_helper.dart';

class TodoSection extends StatefulWidget {
  final DateTime selectedDay;
  const TodoSection({super.key, required this.selectedDay});

  @override
  State<TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection> {
  final _todoService = TodoService();

  /// Show a bottom sheet with edit or delete actions
  void _showTaskOptions(Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => AddTodoBottomSheet(
                      initialDate: todo.date,
                      todoToEdit: todo,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Show confirmation dialog
                  final confirmed = await MessageHelper.showConfirmDialog(
                    context: context,
                    title: 'Delete Task',
                    message: 'Are you sure you want to delete "${todo.title}"?',
                  );

                  if (confirmed) {
                    try {
                      await _todoService.deleteTodo(todo.id);
                      if (mounted) {
                        MessageHelper.showSuccess(context, 'Task deleted');
                      }
                    } catch (e) {
                      if (mounted) {
                        MessageHelper.showError(context, 'Failed to delete: $e');
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'To Do',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<List<Todo>>(
            stream: _todoService.getTodosForDay(widget.selectedDay),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final todos = snapshot.data!;
              if (todos.isEmpty) {
                return SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'No tasks for today. Tap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: todos.map((todo) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            todo.done
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                todo.done ? Colors.deepPurple : Colors.grey,
                          ),
                          onPressed: () async {
                            try {
                              await _todoService.toggleDone(todo.id, todo.done);
                            } catch (e) {
                              if (mounted) {
                                MessageHelper.showError(
                                    context, 'Failed to update: $e');
                              }
                            }
                          },
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: todo.done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () => _showTaskOptions(todo),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}