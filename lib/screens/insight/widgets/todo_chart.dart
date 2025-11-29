import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/todo_service.dart';
import '../../../models/todo_model.dart';

/// Bar chart showing completed todos for each day of the week
/// Displays Monday to Sunday with completion count
class TodoChart extends StatefulWidget {
  final DateTime selectedWeek; // Any date in the target week

  const TodoChart({super.key, required this.selectedWeek});

  @override
  State<TodoChart> createState() => _TodoChartState();
}

class _TodoChartState extends State<TodoChart> {
  final _todoService = TodoService();
  List<Todo> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TodoChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when week changes
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _loadData();
    }
  }

  /// Get Monday of the week
  DateTime _getMonday(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Load todos for the selected week
  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final monday = _getMonday(widget.selectedWeek);
      final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

      final todos = await _todoService.getTodosBetween(monday, sunday);
      
      if (mounted) {
        setState(() {
          _todos = todos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chart data: $e')),
        );
      }
    }
  }

  /// Group completed todos by day of week
  Map<String, int> _groupByDay() {
    final monday = _getMonday(widget.selectedWeek);
    
    // Initialize all 7 days with 0
    final Map<String, int> grouped = {
      for (int i = 0; i < 7; i++)
        _formatDate(monday.add(Duration(days: i))): 0,
    };

    // Count completed todos for each day
    for (var todo in _todos) {
      if (!todo.done) continue; // Only count completed todos
      
      final dateKey = _formatDate(todo.date);
      if (grouped.containsKey(dateKey)) {
        grouped[dateKey] = grouped[dateKey]! + 1;
      }
    }

    return grouped;
  }

  /// Format date as "YYYY-MM-DD"
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Get day label (Mon, Tue, etc.)
  String _getDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Container(
          height: 280,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final grouped = _groupByDay();
    final monday = _getMonday(widget.selectedWeek);

    // Check if there's any completed todos
    final hasData = grouped.values.any((count) => count > 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title
            const Text(
              "To-Do Completed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Chart or empty state
            !hasData
                ? Container(
                    height: 220,
                    alignment: Alignment.center,
                    child: Text(
                      "No completed tasks this week",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          // Bottom titles (day names)
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= 7) {
                                  return const SizedBox();
                                }
                                final date = monday.add(Duration(days: index));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getDayLabel(date),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Left titles (counts)
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),

                        // Bars (one per day)
                        barGroups: List.generate(7, (index) {
                          final date = monday.add(Duration(days: index));
                          final dateKey = _formatDate(date);
                          final count = grouped[dateKey] ?? 0;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                width: 14,
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.deepPurple.shade400
                                    .withOpacity(count == 0 ? 0.18 : 0.9),
                              ),
                            ],
                          );
                        }),

                        // Touch interaction
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.white,
                            tooltipPadding: const EdgeInsets.all(10),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date =
                                  monday.add(Duration(days: groupIndex));
                              return BarTooltipItem(
                                '${rod.toY.toInt()} tasks\n${_getDayLabel(date)}',
                                TextStyle(
                                  color: Colors.deepPurple.shade400,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}