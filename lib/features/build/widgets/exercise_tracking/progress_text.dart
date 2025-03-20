import 'package:flutter/material.dart';

class ProgressText extends StatelessWidget {
  const ProgressText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "2 of 5 days",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA764FF),
          ),
        ),
        Text(
          "This week",
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