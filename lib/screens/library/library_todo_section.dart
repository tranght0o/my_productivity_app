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
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _todoService.getTodosByMonthStream(
        _selectedMonth.year,
        _selectedMonth.month,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final originalTodos = snapshot.data ?? [];

        // filtered in query
        final searchedTodos = widget.searchQuery.isEmpty
            ? originalTodos
            : originalTodos
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
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.deepPurple.shade400,
                      size: 20,
                    ),
                    label: Text(
                      '${_selectedMonth.month}/${_selectedMonth.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple.shade400,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.deepPurple.shade400,
                    ),
                    onPressed: _toggleSortOrder,
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
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.deepPurple.shade300,
                    ),
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedDays.length,
                      itemBuilder: (context, index) {
                        final day = sortedDays[index];
                        final dayTodos = todosByDay[day]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date label
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 6),
                              child: Text(
                                '${day.day}/${day.month}/${day.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),

                            // Task cards
                            Column(
                              children: dayTodos.map((todo) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    minVerticalPadding: 12,
                                    leading: GestureDetector(
                                      onTap: () async {
                                        try {
                                          await _todoService.toggleDone(
                                              todo.id, todo.done);
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to update: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: Icon(
                                        todo.done
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: todo.done
                                            ? Colors.deepPurple.shade400
                                            : Colors.grey.shade400,
                                        size: 26,
                                      ),
                                    ),
                                    title: Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: todo.done
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: todo.done
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.grey.shade500,
                                      ),
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
      },
    );
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
    }
  }

  /// Change between ascending and descending date order
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  /// Show bottom sheet options
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
}
