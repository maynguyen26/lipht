import 'package:flutter/material.dart';
import 'progress_text.dart';
import 'weekday_indicators.dart';

class ExerciseTrackingCard extends StatelessWidget {
  const ExerciseTrackingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Exercise Days",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA764FF),
            ),
          ),
          const SizedBox(height: 15),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ProgressText(),
              WeekdayIndicators(),
            ],
          ),
        ],
      ),
    );
  }
}