import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../services/todo_service.dart';
import '../../models/todo_model.dart';
import '../../widgets/add_todo_bottom_sheet.dart';

class LibraryTodoSection extends StatefulWidget {
  const LibraryTodoSection({super.key});

  @override
  State<LibraryTodoSection> createState() => _LibraryTodoSectionState();
}

class _LibraryTodoSectionState extends State<LibraryTodoSection> {
  final _todoService = TodoService();

  // Currently selected month (default = current month)
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // List of all todos loaded from the service
  List<Todo> _todos = [];

  // Whether dates are sorted ascending (oldest first)
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  /// Fetch all todos once (you should already have getAllTodosOnce in your service)
  Future<void> _fetchTodos() async {
    final allTodos = await _todoService.getAllTodosOnce();
    setState(() {
      _todos = allTodos;
    });
  }

  /// Show a month picker dialog (allows choosing both month and year)
  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        // Only keep month and year (ignore day)
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  /// Toggle between ascending / descending day order
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  /// Open bottom sheet with Edit / Delete actions for a todo
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
                  _fetchTodos(); // refresh list after deletion
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
    // Filter todos to only include those in the selected month
    final filteredTodos = _todos.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList();

    // Count total and completed tasks for summary
    final totalCount = filteredTodos.length;
    final doneCount = filteredTodos.where((t) => t.done).length;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

    // Group todos by day
    final Map<DateTime, List<Todo>> todosByDay = {};
    for (var todo in filteredTodos) {
      final day = DateTime(todo.date.year, todo.date.month, todo.date.day);
      todosByDay.putIfAbsent(day, () => []).add(todo);
    }

    // Sort days ascending or descending depending on user selection
    final sortedDays = todosByDay.keys.toList()
      ..sort((a, b) => _isAscending ? a.compareTo(b) : b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --------------------------
        //  Month picker + sort toggle
        // --------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Button to open month picker
              TextButton.icon(
                onPressed: _pickMonth,
                icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                label: Text(
                  '${_selectedMonth.month}/${_selectedMonth.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              // Icon button to toggle sort direction
              IconButton(
                icon: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.deepPurple,
                ),
                onPressed: _toggleSortOrder,
                tooltip: 'Toggle sort order',
              ),
            ],
          ),
        ),

        // ===================================================
        //  Summary section (shows total tasks + done + bar)
        // ===================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$totalCount tasks, $doneCount done',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.grey[200],
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),

        // --------------------------
        //  Todos grouped by day
        // --------------------------
        Expanded(
          child: sortedDays.isEmpty
              ? const Center(child: Text('No tasks for this month'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    final dayTodos = todosByDay[day]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day title
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${day.day}/${day.month}/${day.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        // All todos for that day
                        Column(
                          children: dayTodos.map((todo) {
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
                                    color: todo.done
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                  ),
                                  // Toggle done state
                                  onPressed: () => _todoService.toggleDone(
                                    todo.id,
                                    todo.done,
                                  ),
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
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.grey),
                                  onPressed: () => _showTaskOptions(todo),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
