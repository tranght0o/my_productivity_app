import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../services/todo_service.dart';
import '../../models/todo_model.dart';
import '../../widgets/add_todo_bottom_sheet.dart';

class LibraryTodoSection extends StatefulWidget {
  final String searchQuery;
  const LibraryTodoSection({super.key, this.searchQuery = ''});

  @override
  State<LibraryTodoSection> createState() => _LibraryTodoSectionState();
}

class _LibraryTodoSectionState extends State<LibraryTodoSection> {
  final _todoService = TodoService();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Todo> _todos = [];
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  /// Load todos for selected month from Firestore (OPTIMIZED)
  Future<void> _fetchTodos() async {
    try {
      final todos = await _todoService.getTodosByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
      setState(() {
        _todos = todos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load todos: $e')),
        );
      }
    }
  }

  /// Show month picker for filtering by month
  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _fetchTodos();
    }
  }

  /// Change between ascending and descending date order
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

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
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await _todoService.deleteTodo(todo.id);
                    setState(() {
                      _todos.removeWhere((t) => t.id == todo.id);
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete: $e')),
                      );
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
    //filtered in query
    final searchedTodos = widget.searchQuery.isEmpty
        ? _todos
        : _todos
            .where((t) => t.title
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase()))
            .toList();

    final totalCount = searchedTodos.length;
    final doneCount = searchedTodos.where((t) => t.done).length;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

    // Group todos by day
    final Map<DateTime, List<Todo>> todosByDay = {};
    for (var todo in searchedTodos) {
      final day = DateTime(todo.date.year, todo.date.month, todo.date.day);
      todosByDay.putIfAbsent(day, () => []).add(todo);
    }

    final sortedDays = todosByDay.keys.toList()
      ..sort((a, b) => _isAscending ? a.compareTo(b) : b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: month picker + sort button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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

        // Progress summary
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

        // Todo list
        Expanded(
          child: sortedDays.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks this month',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sortedDays.length,
                  itemBuilder: (context, index) {
                    final day = sortedDays[index];
                    final dayTodos = todosByDay[day]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  onPressed: () async {
                                    try {
                                      await _todoService.toggleDone(
                                          todo.id, todo.done);
                                      setState(() {
                                        todo.done = !todo.done;
                                      });
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Failed to update: $e')),
                                        );
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