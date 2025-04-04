import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyWeightChart extends StatefulWidget {
  const WeeklyWeightChart({Key? key}) : super(key: key);

  @override
  State<WeeklyWeightChart> createState() => _WeeklyWeightChartState();
}

class _WeeklyWeightChartState extends State<WeeklyWeightChart> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<FlSpot> _weightSpots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeightData();
  }

  Future<void> _fetchWeightData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6));
    final dateLabels = List.generate(7, (i) => DateFormat('yyyy-MM-dd').format(startDate.add(Duration(days: i))));
    final Map<String, double> dateToWeight = { for (var d in dateLabels) d: 0 };

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workoutLogs')
        .where('date', isGreaterThanOrEqualTo: dateLabels.first)
        .where('date', isLessThanOrEqualTo: dateLabels.last)
        .get();

    for (var doc in snapshot.docs) {
      final date = doc['date'];
      final exercises = doc['exercises'] as Map<String, dynamic>;

      double dailyTotal = 0;
      for (var sets in exercises.values) {
        if (sets is List) {
          for (var set in sets) {
            final weight = double.tryParse(set['weight'] ?? '0') ?? 0;
            final reps = double.tryParse(set['reps'] ?? '0') ?? 0;
            dailyTotal += weight * reps;
          }
        }
      }

      if (dateToWeight.containsKey(date)) {
        dateToWeight[date] = dateToWeight[date]! + dailyTotal;
      }
    }

    setState(() {
      _weightSpots = dateLabels.asMap().entries.map((entry) {
        final index = entry.key;
        final date = entry.value;
        return FlSpot(index.toDouble(), dateToWeight[date] ?? 0);
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weekly Weight Lifted",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA764FF),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade50,
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: _weightSpots.isEmpty
              ? const Text("No weight data this week.")
              : SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                              return Text(
                                DateFormat('E').format(day),
                                style: const TextStyle(fontSize: 12, color: Color(0xFFA764FF)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, _) {
                              if (value == 0 || value % 100 == 0) {
                                return Text('${value.toInt()}kg', style: const TextStyle(fontSize: 11, color: Color(0xFFA764FF)));
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _weightSpots,
                          isCurved: true,
                          color: const Color(0xFFA764FF),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFA764FF).withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
