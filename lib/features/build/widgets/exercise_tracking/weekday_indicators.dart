import 'package:flutter/material.dart';
import 'day_indicator.dart';

class WeekdayIndicators extends StatelessWidget {
  final Set<int> daysWorked;

  const WeekdayIndicators({Key? key, required this.daysWorked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        return DayIndicator(
          day: ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
          isActive: daysWorked.contains(index),
        );
      }),
    );
  }
}

