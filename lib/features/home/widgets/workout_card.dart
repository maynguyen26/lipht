import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback? onTap;

  const WorkoutCard({
    Key? key,
    required this.workout,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date if available, otherwise use today's date
    String displayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    if (workout.containsKey('date') && workout['date'] != null) {
      try {
        // Try to parse the date from the workout log
        final date = DateTime.parse(workout['date']);
        displayDate = DateFormat('EEEE, MMMM d').format(date);
      } catch (e) {
        print("Error parsing date: $e");
      }
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFA764FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['programName']?.toString() ?? "Workout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Row(
                      children: [
                        if (workout.containsKey('duration') && workout['duration'] != null)
                        ...[
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: Color(0xFF879FFF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            workout['duration'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF879FFF),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                        if (workout.containsKey('exercises'))
                          Text(
                            workout['exercises'] is List 
                                ? '${(workout['exercises'] as List).length} exercises' 
                                : workout['exercises'] is Map
                                    ? '${(workout['exercises'] as Map).length} exercises'
                                    : 'Exercises logged',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF879FFF),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFA764FF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}