import 'package:flutter/material.dart';
import '../../services/todo_service.dart';
import '../../models/todo_model.dart';
import '../../widgets/add_todo_bottom_sheet.dart';

class TodoSection extends StatefulWidget {
  final DateTime selectedDay;
  const TodoSection({super.key, required this.selectedDay});

  @override
  State<TodoSection> createState() => _TodoSectionState();
}

class _TodoSectionState extends State<TodoSection> {
  final _todoService = TodoService();

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
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  await _todoService.deleteTodo(todo.id);
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
                      'Plan your day by adding a new task',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                          onPressed: () =>
                              _todoService.toggleDone(todo.id, todo.done),
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
