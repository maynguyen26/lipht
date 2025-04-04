import 'package:flutter/material.dart';

class ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onSelect;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final String name = program['name'] ?? 'Unnamed';
    final List days = program['days'] ?? [];
    final List exercises = program['exercises'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9D76C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFA764FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
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
                      const SizedBox(height: 4),
                      Text(
                        days.join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9D76C1),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Enter Workout"),
                ),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: exercises.isEmpty
                  ? const Text(
                      "No exercises listed.",
                      style: TextStyle(color: Color(0xFF9D76C1)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(exercises.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.fitness_center, size: 18, color: Color(0xFF9D76C1)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  exercises[index],
                                  style: const TextStyle(
                                    color: Color(0xFF9D76C1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
