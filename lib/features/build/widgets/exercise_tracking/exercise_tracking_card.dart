import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'day_indicator.dart';
import 'progress_text.dart';
import 'weekday_indicators.dart';

class ExerciseTrackingCard extends StatefulWidget {
  const ExerciseTrackingCard({Key? key}) : super(key: key);

  @override
  State<ExerciseTrackingCard> createState() => _ExerciseTrackingCardState();
}

class _ExerciseTrackingCardState extends State<ExerciseTrackingCard> {
  Stream<List<DateTime>> get _workoutDatesStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workoutLogs')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc['date'] as String)
          .map((dateStr) => DateTime.tryParse(dateStr))
          .where((date) =>
              date != null &&
              date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(days: 1))))
          .cast<DateTime>()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DateTime>>(
      stream: _workoutDatesStream,
      builder: (context, snapshot) {
        final workoutDates = snapshot.data ?? [];
        final daysWorked = workoutDates.map((d) => d.weekday % 7).toSet();

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
                children: [
                  ProgressText(activeDays: daysWorked.length),
                  WeekdayIndicators(daysWorked: daysWorked),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
