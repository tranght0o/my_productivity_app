import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/mood_service.dart';
import '../../../models/mood_model.dart';
import '../../../utils/date_range_helper.dart';
import 'time_range_dropdown.dart';

class MoodChart extends StatefulWidget {
  const MoodChart({super.key});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  final _moodService = MoodService();
  TimeRange _selectedRange = TimeRange.thisWeek;
  List<Mood> _moods = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final moods = await _moodService.getAllMoodsOnce();
    setState(() => _moods = moods);
  }

  @override
  Widget build(BuildContext context) {
    final range = DateRangeHelper.getRange(_selectedRange);
    final start = range['start']!;
    final end = range['end']!;

    final filtered =
        _moods.where((m) => m.date.isAfter(start) && m.date.isBefore(end)).toList();

    final map = <int, List<int>>{};
    for (var m in filtered) {
      final day = m.date.day;
      map.putIfAbsent(day, () => []).add(m.moodValue);
    }

    final avg = <int, double>{};
    map.forEach((day, list) {
      avg[day] = list.reduce((a, b) => a + b) / list.length;
    });

    final sorted = Map.fromEntries(
      avg.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
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
                const Text("Mood Chart",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: LineChart(
                      LineChartData(
                        minY: 1,
                        maxY: 5,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
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
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)), // Hide top
                          rightTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false)), // Hide right
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            barWidth: 3,
                            color: const Color(0xFF7E57C2),
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF7E57C2).withOpacity(0.3),
                                  Colors.transparent
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            spots: sorted.entries
                                .map((e) => FlSpot(
                                    e.key.toDouble(), e.value.toDouble()))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
