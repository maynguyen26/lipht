import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final double percent;
  final Color color;

  const PieChartMetric({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.percent,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                  sections: [
                    PieChartSectionData(
                      value: percent * 82,
                      color: color,
                      radius: 4,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: (1 - percent) * 82,
                      color: color.withAlpha(80),
                      radius: 4,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: 18,
                      color: Colors.white,
                      radius: 4,
                      title: '',
                    ),
                  ],
                  startDegreeOffset: 122.5,
                ),
              ),
              Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${(percent * 100).toInt()}%",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}