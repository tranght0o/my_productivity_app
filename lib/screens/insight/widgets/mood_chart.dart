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
        (m) => m.date.year == date.year && 
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
      return Card(
        margin: const EdgeInsets.all(8),
        child: Container(
          height: 280,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final spots = _createSpots();
    final hasData = spots.isNotEmpty;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mood Chart",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            !hasData
                ? Container(
                    height: 220,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mood, 
                            size: 48, 
                            color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          "No mood data this week",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
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
                                if (index < 0 || index >= 7) {
                                  return const SizedBox();
                                }
                                return Text(
                                  _getDayLabel(index),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 28,
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
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.3,
                            barWidth: 3,
                            color: const Color(0xFF7E57C2),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: const Color(0xFF7E57C2),
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF7E57C2).withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            spots: spots,
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => Colors.deepPurple,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final dayIndex = spot.x.toInt();
                                final moodValue = spot.y.toInt();
                                final emoji = _emojiForValue(moodValue);
                                
                                return LineTooltipItem(
                                  '$emoji ${_getDayLabel(dayIndex)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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