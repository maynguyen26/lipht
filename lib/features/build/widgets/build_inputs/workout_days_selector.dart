import 'package:flutter/material.dart';

class WorkoutDaysSelector extends StatefulWidget {
  final Set<String> selectedDays;
  final void Function(Set<String>) onChanged;

  const WorkoutDaysSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  State<WorkoutDaysSelector> createState() => _WorkoutDaysSelectorState();
}

class _WorkoutDaysSelectorState extends State<WorkoutDaysSelector> {
  final List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> _fullDays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
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
            "Workout Days",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA764FF),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_days.length, (index) {
              final abbrev = _fullDays[index];
              final display = _days[index];
              final isSelected = widget.selectedDays.contains(abbrev);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    widget.selectedDays.remove(abbrev);
                  } else {
                    widget.selectedDays.add(abbrev);
                  }
                });
                widget.onChanged(widget.selectedDays);
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFA764FF)
                      : Colors.white.withOpacity(0.5),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFA764FF)
                        : const Color(0xFFDDA7F6),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFDDA7F6),
                  ),
                ),
              ),
            );

            }),
          ),
        ],
      ),
    );
  }
}
