import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDataResult {
  final String sleepAverage;
  final int caloriesConsumed;
  final List<Map<String, dynamic>> todaysWorkouts;
  final String motivationalQuote;

  UserDataResult({
    required this.sleepAverage,
    required this.caloriesConsumed,
    required this.todaysWorkouts,
    required this.motivationalQuote,
  });
}

class HomeDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserDataResult> loadAllUserData(User user) async {
    final results = await Future.wait([
      _loadSleepData(user),
      _loadNutritionData(user),
      _loadTodaysWorkouts(user),
      _loadMotivationalQuote(),
    ]);

    return UserDataResult(
      sleepAverage: results[0] as String,
      caloriesConsumed: results[1] as int,
      todaysWorkouts: results[2] as List<Map<String, dynamic>>,
      motivationalQuote: results[3] as String,
    );
  }

  Future<String> _loadSleepData(User user) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(Duration(days: 7));
      final sevenDaysAgoStr = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleepLogs')
          .where('date', isGreaterThanOrEqualTo: sevenDaysAgoStr)
          .get();
      
      final sleepLogs = querySnapshot.docs.map((doc) => doc.data()).toList();
      
      if (sleepLogs.isNotEmpty) {
        int totalMinutes = sleepLogs.fold(0, (sum, log) => sum + (log['durationMinutes'] as int));
        final averageMinutes = totalMinutes ~/ sleepLogs.length;
        final hours = averageMinutes ~/ 60;
        final minutes = averageMinutes % 60;
        
        return "${hours}h ${minutes}m";
      }
      return "0h 0m";
    } catch (e) {
      print("Error loading sleep data: $e");
      return "0h 0m";
    }
  }

  Future<int> _loadNutritionData(User user) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealLogs')
          .where('date', isEqualTo: today)
          .get();
      
      final mealLogs = querySnapshot.docs.map((doc) => doc.data()).toList();
      
      int totalCalories = 0;
      
      for (var meal in mealLogs) {
        totalCalories += meal['calories'] as int;
      }
      
      return totalCalories;
    } catch (e) {
      print("Error loading nutrition data: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _loadTodaysWorkouts(User user) async {
    try {
      // Get today's date in the format stored in Firestore
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      print("Fetching workouts for date: $today");
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workoutLogs')
          .where('date', isEqualTo: today)
          .get();
      
      print("Found ${querySnapshot.docs.length} workouts for today");
      
      List<Map<String, dynamic>> todaysWorkouts = [];
      
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Add the document ID to the data
        
        // Print the workout data for debugging
        print("Workout data: ${data.toString()}");
        
        // Check if important fields exist
        if (data.containsKey('duration')) {
          print("Duration: ${data['duration']}");
        } else {
          print("Duration field not found");
        }
        
        if (data.containsKey('exercises')) {
          print("Exercises: ${data['exercises']}");
          if (data['exercises'] is List) {
            print("Exercises count: ${(data['exercises'] as List).length}");
          } else {
            print("Exercises is not a List type: ${data['exercises'].runtimeType}");
          }
        } else {
          print("Exercises field not found");
        }
        
        todaysWorkouts.add(data);
      }
      
      return todaysWorkouts;
    } catch (e) {
      print("Error loading workout data: $e");
      return [];
    }
  }

  Future<String> _loadMotivationalQuote() async {
    try {
      // Use only predefined hard-coded quotes
      final quotes = [
        "Sweat today, shine tomorrow.",
        "Your progress is one step ahead of your excuses.",
        "Strong mind, strong body.",
        "The pain you feel today will be the strength you feel tomorrow.",
        "Success starts with self-discipline.",
        "Fall in love with taking care of yourself.",
        "The hardest lift of all is lifting yourself up.",
        "Train your mind to see the good in every workout.",
        "Fitness is not about being better than someone else. It's about being better than you used to be.",
        "Your future self will thank you for this workout.",
        "A one-hour workout is 4% of your day. No excuses.",
        "The only bad workout is the one that didn't happen.",
        "Push yourself because no one else is going to do it for you.",
        "Don't count the days, make the days count.",
        "It never gets easier, you just get stronger.",
        "Results happen over time, not overnight. Work hard, stay consistent.",
        "Stop wishing, start doing.",
        "Fitness is a journey, not a destination.",
        "Strive for progress, not perfection.",
        "Your only limit is you.",
        "When you feel like quitting, think about why you started.",
        "The body achieves what the mind believes.",
        "Every workout counts, even the bad ones.",
        "Your sweat is your fat crying.",
        "You don't have to be extreme, just consistent.",
        "The difference between try and triumph is a little 'umph'.",
        "If it doesn't challenge you, it doesn't change you.",
        "Fitness is not a punishment; it's a blessing.",
        "Work hard in silence, let success make the noise.",
        "Train insane or remain the same.",
      ];
      
      return quotes[DateTime.now().millisecond % quotes.length];
    } catch (e) {
      print("Error loading quote: $e");
      return "Every step counts on your wellness journey.";
    }
  }
}