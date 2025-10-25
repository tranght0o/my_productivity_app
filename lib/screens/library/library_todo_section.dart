import 'package:flutter/material.dart';
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

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final allTodos = await _todoService.getAllTodosOnce(); // cần tạo trong service
    setState(() {
      _todos = allTodos;
    });
  }

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
                  _fetchTodos();
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
    // Lọc todo theo tháng được chọn
    final filteredTodos = _todos.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList();

    // Nhóm theo ngày
    final Map<DateTime, List<Todo>> todosByDay = {};
    for (var todo in filteredTodos) {
      final day = DateTime(todo.date.year, todo.date.month, todo.date.day);
      if (!todosByDay.containsKey(day)) {
        todosByDay[day] = [];
      }
      todosByDay[day]!.add(todo);
    }

    final sortedDays = todosByDay.keys.toList()..sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Month: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<DateTime>(
                value: _selectedMonth,
                items: List.generate(12, (index) {
                  final date = DateTime(DateTime.now().year, index + 1);
                  return DropdownMenuItem(
                    value: date,
                    child: Text('${date.month}/${date.year}'),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Content per day
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${day.day}/${day.month}/${day.year}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
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
                                  onPressed: () => _todoService.toggleDone(
                                      todo.id, todo.done),
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
