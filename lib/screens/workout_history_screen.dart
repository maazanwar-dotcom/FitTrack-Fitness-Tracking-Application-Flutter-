import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  String _selectedStat = "Duration"; // "Volume", "Reps" possible
  List<Map<String, dynamic>> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .orderBy('date', descending: true)
        .get();
    setState(() {
      _workouts = snap.docs.map((d) => d.data()).toList();
      _loading = false;
    });
  }

  List<BarChartGroupData> _buildBarData(List<Map<String, dynamic>> workouts) {
    // Group by week (for "last 3 months") and sum durations/volumes/reps
    final now = DateTime.now();
    final Map<int, double> valuesPerWeek = {}; // weekOfYear -> value

    for (var w in workouts) {
      final date = (w['date'] as Timestamp).toDate();
      final weekOfYear = int.parse(DateFormat("w").format(date));
      double value = 0;
      if (_selectedStat == "Duration") {
        value = (w['duration'] ?? 0) / 3600.0; // seconds to hours
      } else if (_selectedStat == "Volume") {
        value = (w['totalVolume'] ?? 0).toDouble();
      } else if (_selectedStat == "Reps") {
        value = (w['exercises'] as List)
            .expand((ex) => ex['sets'] as List)
            .fold<double>(0, (sum, s) => sum + (s['reps'] ?? 0));
      }
      valuesPerWeek[weekOfYear] = (valuesPerWeek[weekOfYear] ?? 0) + value;
    }

    // Only last 12 weeks for "last 3 months"
    final currentWeek = int.parse(DateFormat("w").format(now));
    final weekLabels = List.generate(8, (i) => currentWeek - 7 + i);
    return weekLabels.map((w) {
      final v = valuesPerWeek[w] ?? 0;
      return BarChartGroupData(
        x: w,
        barRods: [
          BarChartRodData(
            toY: v,
            color: Colors.blue,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statOptions = ["Duration", "Volume", "Reps"];
    final now = DateTime.now();
    final weekRange = List.generate(
      8,
      (i) => now.subtract(Duration(days: (7 - i) * 7)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FirebaseAuth.instance.currentUser?.displayName ?? "History",
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top Summary
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Text(
                          _selectedStat == "Duration"
                              ? "${_weeklyTotal().toStringAsFixed(1)} hours"
                              : _selectedStat == "Volume"
                              ? "${_weeklyTotal().toStringAsFixed(0)} kg"
                              : "${_weeklyTotal().toStringAsFixed(0)} reps",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "this week",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Spacer(),
                        DropdownButton<String>(
                          value: "Last 3 months",
                          items: [
                            DropdownMenuItem(
                              value: "Last 3 months",
                              child: Text("Last 3 months"),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                  // Graph
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: AspectRatio(
                      aspectRatio: 1.9,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceBetween,
                          barGroups: _buildBarData(_workouts),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (_selectedStat == "Duration") {
                                    return Text("${value.round()} hrs");
                                  } else if (_selectedStat == "Volume") {
                                    return Text("${value.round()} kg");
                                  } else {
                                    return Text("${value.round()}");
                                  }
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx >= 0 && idx < weekRange.length) {
                                    final d = weekRange[idx];
                                    return Text(DateFormat('MMM d').format(d));
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),
                  // Stat Switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: statOptions.map((s) {
                        final selected = _selectedStat == s;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: ChoiceChip(
                            label: Text(s),
                            selected: selected,
                            onSelected: (val) {
                              if (!selected) setState(() => _selectedStat = s);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Dashboard (static for now)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _DashboardButton(
                          icon: Icons.bar_chart,
                          label: "Statistics",
                        ),
                        _DashboardButton(
                          icon: Icons.fitness_center,
                          label: "Exercises",
                        ),
                        _DashboardButton(
                          icon: Icons.monitor_weight,
                          label: "Measures",
                        ),
                        _DashboardButton(
                          icon: Icons.calendar_today,
                          label: "Calendar",
                        ),
                      ],
                    ),
                  ),
                  // Workouts List
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Workouts",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        ..._workouts.map(_WorkoutHistoryTile).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  double _weeklyTotal() {
    if (_workouts.isEmpty) return 0;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 7));
    double total = 0;
    for (var w in _workouts) {
      final d = (w['date'] as Timestamp).toDate();
      if (d.isAfter(weekStart) && d.isBefore(weekEnd)) {
        if (_selectedStat == "Duration") {
          total += (w['duration'] ?? 0) / 3600.0;
        } else if (_selectedStat == "Volume") {
          total += (w['totalVolume'] ?? 0).toDouble();
        } else if (_selectedStat == "Reps") {
          total += (w['exercises'] as List)
              .expand((ex) => ex['sets'] as List)
              .fold<double>(0, (sum, s) => sum + (s['reps'] ?? 0));
        }
      }
    }
    return total;
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DashboardButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        minimumSize: Size(140, 44),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: () {},
    );
  }
}

Widget _WorkoutHistoryTile(Map<String, dynamic> workout) {
  final exercises = (workout['exercises'] as List?) ?? [];
  final date = (workout['date'] as Timestamp).toDate();
  final title = (workout['routineTitle'] ?? 'Workout').toString();
  final duration = workout['duration'] ?? 0;
  final volume = workout['totalVolume'] ?? 0;
  // For demo, "records" is a random number
  final records = 3;

  return Card(
    margin: EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: Colors.grey[300]),
              SizedBox(width: 12),
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "User",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12),
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(date),
                style: TextStyle(color: Colors.grey),
              ),
              Spacer(),
              Icon(Icons.more_horiz),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text("Time ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_formatDuration(duration)),
              SizedBox(width: 18),
              Text("Volume ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${volume.toStringAsFixed(0)} kg"),
              SizedBox(width: 18),
              Text("Records ", style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.emoji_events, color: Colors.amber, size: 18),
              Text(" $records"),
            ],
          ),
          SizedBox(height: 8),
          ...exercises.map((ex) {
            final exName = ex['name'] ?? '';
            final sets = (ex['sets'] as List?)?.length ?? 0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, size: 18),
                  SizedBox(width: 6),
                  Text("$sets sets $exName", style: TextStyle(fontSize: 15)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}

String _formatDuration(int seconds) {
  final d = Duration(seconds: seconds);
  if (d.inHours > 0) {
    return "${d.inHours}h ${d.inMinutes % 60}min";
  }
  return "${d.inMinutes}min";
}
