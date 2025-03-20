import 'package:flutter/material.dart';
import 'pie_chart_metric.dart';

class PieChartCard extends StatelessWidget {
  const PieChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade50,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Daily Progress Goals",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA764FF),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              // Heart rate pie chart
              PieChartMetric(
                icon: Icons.monitor_heart_outlined,
                title: "Heart Rate",
                value: "128",
                unit: "BPM",
                percent: 1,
                color: Color(0xFFA764FF),
              ),
              
              // Calories burned pie chart
              PieChartMetric(
                icon: Icons.local_fire_department_outlined,
                title: "Calories",
                value: "385",
                unit: "kcal",
                percent: 0.65,
                color: Color(0xFFFF6B6B),
              ),
              
              // Steps pie chart
              PieChartMetric(
                icon: Icons.directions_run_outlined,
                title: "Steps",
                value: "6,243",
                unit: "steps",
                percent: 0.52,
                color: Color(0xFF4ECDC4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}