import 'package:flutter/material.dart';
import 'day_indicator.dart';

class WeekdayIndicators extends StatelessWidget {
  const WeekdayIndicators({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        // Define which days are active (completed)
        bool isActive = index == 0 || index == 4;
        return DayIndicator(
          day: ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
          isActive: isActive,
        );
      }),
    );
  }
}