import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart' as app_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lipht/features/sleep/screens/sleep_screen.dart';
import 'package:lipht/features/build/screens/build_program_screen.dart';
import 'package:lipht/presentation/screens/main_layout.dart';
import 'package:lipht/features/home/data/home_data_service.dart';
import 'package:lipht/features/home/widgets/stat_card.dart';
import 'package:lipht/features/home/widgets/workout_card.dart';
import 'package:lipht/features/home/widgets/empty_workout_card.dart';
import 'package:lipht/features/home/widgets/quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeDataService _dataService = HomeDataService();
  
  // State variables for user data
  bool _isLoading = true;
  String _sleepAverage = "0h 0m";
  int _caloriesConsumed = 0;
  List<Map<String, dynamic>> _todaysWorkouts = [];
  String _motivationalQuote = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final results = await _dataService.loadAllUserData(user);
      
      setState(() {
        _sleepAverage = results.sleepAverage;
        _caloriesConsumed = results.caloriesConsumed;
        _todaysWorkouts = results.todaysWorkouts;
        _motivationalQuote = results.motivationalQuote;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning,";
    } else if (hour < 17) {
      return "Good afternoon,";
    } else {
      return "Good evening,";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final user = authProvider.user;

    final greeting = _getGreeting();
    final name = user != null ? user.firstName ?? "there" : "there";

    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)))
        : Container(
            color: const Color(0xFFF9EDFF),
            child: SafeArea(
              child: RefreshIndicator(
                color: Color(0xFFA764FF),
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with greeting and profile
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF9D76C1),
                                  ),
                                ),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFA764FF),
                                  ),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFFDDA7F6),
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 25),
                        
                        // Motivational quote card
                        QuoteCard(quote: _motivationalQuote),
                        
                        SizedBox(height: 25),
                        
                        // Quick stats section - Today's Progress
                        Text(
                          "Today's Progress",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA764FF),
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            StatCard(
                              title: "Sleep",
                              value: _sleepAverage,
                              subtitle: "Average",
                              icon: Icons.bedtime,
                              color: Color(0xFFA764FF),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainLayout(
                                      currentIndex: 3,
                                      child: SleepScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            StatCard(
                              title: "Nutrition",
                              value: "$_caloriesConsumed",
                              subtitle: "Calories",
                              icon: Icons.restaurant,
                              color: Color(0xFF879FFF),
                              onTap: () {
                                // Navigate to Nutrition/Fuel screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainLayout(
                                      currentIndex: 2,
                                      child: Container(), // Replace with FuelScreen
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 25),
                        
                        // Today's workouts section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Workouts",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA764FF),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BuildProgramScreen(),
                                  ),
                                ).then((_) => _loadUserData());
                              },
                              child: Text(
                                "New Program",
                                style: TextStyle(
                                  color: Color(0xFF879FFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _todaysWorkouts.isEmpty
                            ? EmptyWorkoutCard(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BuildProgramScreen(),
                                    ),
                                  ).then((_) => _loadUserData());
                                },
                              )
                            : Column(
                                children: _todaysWorkouts
                                    .map((workout) => WorkoutCard(
                                          workout: workout,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BuildProgramScreen(),
                                              ),
                                            ).then((_) => _loadUserData());
                                          },
                                        ))
                                    .toList(),
                              ),
                        
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}