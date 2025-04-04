import 'package:flutter/material.dart';

class DayIndicator extends StatelessWidget {
  final String day;
  final bool isActive;

  const DayIndicator({
    Key? key,
    required this.day,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Container(
            height: 36,
            width: 12,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFA764FF)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFFA764FF)
                  : Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
