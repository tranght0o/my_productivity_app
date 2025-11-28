import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/habit_log_service.dart';
import '../../../models/habit_log_model.dart';

/// Bar chart showing completed habits for each day of the week
/// Displays total number of habits marked as done per day
class HabitChart extends StatefulWidget {
  final DateTime selectedWeek; // Any date in the target week

  const HabitChart({super.key, required this.selectedWeek});

  @override
  State<HabitChart> createState() => _HabitChartState();
}

class _HabitChartState extends State<HabitChart> {
  final _habitLogService = HabitLogService();
  List<HabitLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void didUpdateWidget(HabitChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when week changes
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _loadLogs();
    }
  }

  /// Get Monday of the week
  DateTime _getMonday(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Load habit logs for the selected week
  Future<void> _loadLogs() async {
    setState(() => _loading = true);

    try {
      final monday = _getMonday(widget.selectedWeek);
      final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

      final logs = await _habitLogService.getLogsBetween(monday, sunday);
      
      if (mounted) {
        setState(() {
          _logs = logs;
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

  /// Group completed habits by day
  Map<String, int> _groupByDay() {
    final monday = _getMonday(widget.selectedWeek);
    
    // Initialize all 7 days with 0
    final Map<String, int> grouped = {
      for (int i = 0; i < 7; i++)
        _formatDate(monday.add(Duration(days: i))): 0,
    };

    // Count completed habits for each day
    for (var log in _logs) {
      if (!log.done) continue; // Only count completed habits
      
      // Parse dayKey (format: "YYYY-MM-DD" or "YYYY-M-D")
      final parts = log.dayKey.split('-');
      if (parts.length == 3) {
        try {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          final dateKey = _formatDate(date);
          if (grouped.containsKey(dateKey)) {
            grouped[dateKey] = grouped[dateKey]! + 1;
          }
        } catch (_) {
          // Skip invalid dayKey
        }
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
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          height: 280,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final grouped = _groupByDay();
    final monday = _getMonday(widget.selectedWeek);

    // Check if there's any completed habits
    final hasData = grouped.values.any((count) => count > 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title
            const Text(
              "Habits Completed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Chart or empty state
            !hasData
                ? Container(
                    height: 220,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.repeat, 
                            size: 48, 
                            color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          "No completed habits this week",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
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
                          // Left titles (count)
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
                        // Bar groups (one for each day)
                        barGroups: List.generate(7, (index) {
                          final date = monday.add(Duration(days: index));
                          final dateKey = _formatDate(date);
                          final count = grouped[dateKey] ?? 0;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                width: 18,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFCE93D8), // Light purple/pink
                                    Color(0xFF7B1FA2), // Deep purple
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ],
                          );
                        }),
                        // Touch interaction
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.purple,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date = monday.add(Duration(days: groupIndex));
                              return BarTooltipItem(
                                '${rod.toY.toInt()} habits\n${_getDayLabel(date)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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