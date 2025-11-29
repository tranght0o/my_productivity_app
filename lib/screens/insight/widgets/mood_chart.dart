// lib/screens/insight/widgets/mood_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/mood_service.dart';
import '../../../models/mood_model.dart';

/// Line chart showing mood trend for each day of the week
/// Y-axis shows emoji faces (1-5 scale), X-axis shows day names
class MoodChart extends StatefulWidget {
  final DateTime selectedWeek;

  const MoodChart({super.key, required this.selectedWeek});

  @override
  State<MoodChart> createState() => _MoodChartState();
}

class _MoodChartState extends State<MoodChart> {
  final _moodService = MoodService();
  List<Mood> _moods = [];
  bool _loading = true;

  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😢', 'value': 1, 'label': 'Terrible'},
    {'emoji': '😞', 'value': 2, 'label': 'Bad'},
    {'emoji': '😐', 'value': 3, 'label': 'Okay'},
    {'emoji': '😊', 'value': 4, 'label': 'Good'},
    {'emoji': '🤩', 'value': 5, 'label': 'Amazing'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(MoodChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeek != widget.selectedWeek) {
      _loadData();
    }
  }

  DateTime _getMonday(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final monday = _getMonday(widget.selectedWeek);
      final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59));

      final moods = await _moodService.getMoodsBetween(monday, sunday);
      
      if (mounted) {
        setState(() {
          _moods = moods;
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

  String _emojiForValue(int value) {
    final match = _moodOptions.firstWhere(
      (e) => e['value'] == value,
      orElse: () => {'emoji': '?'},
    );
    return match['emoji'];
  }

  List<FlSpot> _createSpots() {
    final monday = _getMonday(widget.selectedWeek);
    final spots = <FlSpot>[];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));

      final mood = _moods.firstWhere(
        (m) =>
            m.date.year == date.year &&
            m.date.month == date.month &&
            m.date.day == date.day,
        orElse: () => Mood(
          id: '',
          userId: '',
          date: date,
          moodValue: 0,
        ),
      );

      if (mood.moodValue > 0) {
        spots.add(FlSpot(i.toDouble(), mood.moodValue.toDouble()));
      }
    }

    return spots;
  }

  String _getDayLabel(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          height: 280,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final spots = _createSpots();
    final hasData = spots.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mood Chart",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            !hasData
                ? Container(
                    height: 220,
                    alignment: Alignment.center,
                    child: Text(
                      "No mood data this week",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 6,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1, 
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index > 6) {
                                  return const SizedBox();
                                }
                                return Text(
                                  _getDayLabel(index),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),

                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                if (value < 1 || value > 5 || value != value.roundToDouble()) {
                                  return const SizedBox();
                                }
                                return Text(
                                  _emojiForValue(value.toInt()),
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ),

                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),

                        minY: 1,
                        maxY: 5,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),

                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.25,
                            barWidth: 3,
                            color: Colors.deepPurple.shade400,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: Colors.deepPurple.shade400,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.deepPurple.shade400.withOpacity(0.12),
                            ),
                            spots: spots,
                          ),
                        ],

                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => Colors.white,
                            tooltipPadding: const EdgeInsets.all(10),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final dayIndex = spot.x.toInt();
                                final moodValue = spot.y.toInt();
                                final emoji = _emojiForValue(moodValue);

                                return LineTooltipItem(
                                  '$emoji ${_getDayLabel(dayIndex)}',
                                  TextStyle(
                                    color: Colors.deepPurple.shade400,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                );
                              }).toList();
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
