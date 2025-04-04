import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyWeightChart extends StatelessWidget {
  const WeeklyWeightChart({super.key});

  Stream<List<Map<String, dynamic>>> _weightStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final startDateStr = DateFormat('yyyy-MM-dd').format(start);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workoutLogs')
        .where('date', isGreaterThanOrEqualTo: startDateStr)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _weightStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final workouts = snapshot.data!;
        final Map<String, double> totals = {};

        for (int i = 6; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
          final day = DateFormat('EEE').format(date);
          totals[day] = 0;
        }

        for (final workout in workouts) {
          final dateStr = workout['date'] as String;
          final date = DateTime.tryParse(dateStr);
          if (date == null) continue;

          final day = DateFormat('EEE').format(date);

          if (totals.containsKey(day)) {
            final exercises = Map<String, dynamic>.from(workout['exercises']);
            double totalWeight = 0;

            for (final sets in exercises.values) {
              for (final set in sets) {
                final weight = double.tryParse(set['weight'] ?? '') ?? 0;
                final reps = double.tryParse(set['reps'] ?? '') ?? 0;
                totalWeight += weight * reps;
              }
            }

            totals[day] = (totals[day] ?? 0) + totalWeight;
          }
        }

        final List<FlSpot> spots = [];
        final dayLabels = totals.keys.toList();
        for (int i = 0; i < dayLabels.length; i++) {
          spots.add(FlSpot(i.toDouble(), totals[dayLabels[i]] ?? 0));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Weight Lifted (lbs)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFFA764FF),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 245,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 54,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() < dayLabels.length) {
                            return Text(dayLabels[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFFA764FF),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFA764FF).withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
