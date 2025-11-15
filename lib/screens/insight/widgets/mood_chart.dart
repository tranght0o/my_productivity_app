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

  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😡', 'value': 1},
    {'emoji': '😞', 'value': 2},
    {'emoji': '😐', 'value': 3},
    {'emoji': '😍', 'value': 4},
    {'emoji': '😊', 'value': 5},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final moods = await _moodService.getAllMoodsOnce();
    setState(() => _moods = moods);
  }

  String _emojiForValue(double value) {
    final match = _moodOptions.firstWhere(
      (e) => e['value'] == value.toInt(),
      orElse: () => {'emoji': '?'},
    );
    return match['emoji'];
  }

  @override
  Widget build(BuildContext context) {
    final range = DateRangeHelper.getRange(_selectedRange);
    final start = range['start']!;
    final end = range['end']!;
    final groupUnit = DateRangeHelper.getGroupUnit(_selectedRange, start, end);

    final filtered = _moods
        .where((m) => !m.date.isBefore(start) && !m.date.isAfter(end))
        .toList();

    final Map<String, List<int>> grouped = {};
    for (var m in filtered) {
      final key = DateRangeHelper.makeGroupKey(m.date, groupUnit);
      grouped.putIfAbsent(key, () => []).add(m.moodValue);
    }

    final Map<String, double> avgMap = {};
    grouped.forEach((key, list) {
      avgMap[key] = list.reduce((a, b) => a + b) / list.length;
    });

    final sorted = Map.fromEntries(
      avgMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
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
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= sorted.length) return const SizedBox();
                                final key = sorted.keys.elementAt(index);
                                return Text(
                                  DateRangeHelper.formatLabel(key, groupUnit),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _emojiForValue(value),
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              final xIndex = entry.key.toDouble();
                              final yValue = entry.value.value;
                              return FlSpot(xIndex, yValue);
                            }).toList(),
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
