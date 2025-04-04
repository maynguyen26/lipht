import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;

  const WorkoutCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final String name = workout['programName'] ?? 'Unnamed Program';
    final String date = workout['date'] ?? 'Unknown date';
    final String start = workout['startTime'] ?? '';
    final String end = workout['endTime'] ?? '';
    final duration = start.isNotEmpty && end.isNotEmpty ? "$start - $end" : "Time not recorded";

    final Map<String, dynamic> exercises = Map<String, dynamic>.from(workout['exercises'] ?? {});

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9D76C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFA764FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            padding: const EdgeInsets.all(16),
            child: exercises.isEmpty
                ? const Text(
                    "No exercises recorded.",
                    style: TextStyle(color: Color(0xFF9D76C1)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exercises.entries.map((entry) {
                      final String exerciseName = entry.key;
                      final List sets = List<Map<String, dynamic>>.from(entry.value);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseName,
                            style: const TextStyle(
                              color: Color(0xFF9D76C1),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...sets.map((set) {
                            final String weight = set['weight'] ?? '-';
                            final String reps = set['reps'] ?? '-';
                            final String rpe = set['rpe'] ?? '-';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "$weight kg x $reps reps @ RPE $rpe",
                                style: const TextStyle(
                                  color: Color(0xFF9D76C1),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
