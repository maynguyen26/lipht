import 'package:flutter/material.dart';

class ProgressText extends StatelessWidget {
  final int activeDays;

  const ProgressText({Key? key, required this.activeDays}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$activeDays of 7 days",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA764FF),
          ),
        ),
        const Text(
          "this week",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFA764FF),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
