import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<DateTime>> fetchWorkoutDatesThisWeek() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('workoutLogs')
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
      .where('timestamp', isLessThan: Timestamp.fromDate(endOfWeek))
      .get();

  return snapshot.docs
      .map((doc) => (doc['timestamp'] as Timestamp).toDate())
      .toList();
}
