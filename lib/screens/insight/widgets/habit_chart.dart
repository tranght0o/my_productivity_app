import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/habit_log_service.dart';
import '../../../models/habit_log_model.dart';
import '../../../utils/date_range_helper.dart';
import 'time_range_dropdown.dart';

class HabitChart extends StatefulWidget {
  const HabitChart({super.key});

  @override
  State<HabitChart> createState() => _HabitChartState();
}

class _HabitChartState extends State<HabitChart> {
  final _habitLogService = HabitLogService();
  TimeRange _selectedRange = TimeRange.thisWeek;
  List<HabitLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final logs = await _habitLogService.getLogsBetween(start, now);
    setState(() => _logs = logs);
  }

  @override
  Widget build(BuildContext context) {
    final range = DateRangeHelper.getRange(_selectedRange);
    final start = range['start']!;
    final end = range['end']!;


    final filtered = _logs.where((l) {
      if (!l.done) return false;
      final parts = l.dayKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day);
      return !date.isBefore(s) && !date.isAfter(e);
    }).toList();

    // Group by day
    final map = <int, int>{};
    for (var l in filtered) {
      final day = int.parse(l.dayKey.split('-')[2]);
      map[day] = (map[day] ?? 0) + 1;
    }

    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Habits Completed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TimeRangeDropdown(
                  selected: _selectedRange,
                  onChanged: (r) => setState(() => _selectedRange = r),
                ),
              ],
            ),
            const SizedBox(height: 16),
            sorted.isEmpty
                ? const Center(child: Text("No data in this period"))
                : SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: sorted.entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.toDouble(),
                                width: 16,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD1C4E9),
                                    Color(0xFF7E57C2)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
