import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lipht/features/sleep/screens/add_sleep.dart';
import 'package:lipht/features/sleep/screens/sleep_stats_screen.dart';
import 'package:lipht/presentation/screens/main_layout.dart';
import 'package:lipht/routes/routes.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  String _averageSleepDuration = "0 hrs 0 min";
  List<FlSpot> _sleepSpots = [];
  String _feedbackMessage = "Not enough data to analyze your sleep patterns.";
  
  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }
  
  // Function to load sleep data from Firebase
  Future<void> _loadSleepData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Get sleep logs for the last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(Duration(days: 7));
      final sevenDaysAgoStr = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleepLogs')
          .where('date', isGreaterThanOrEqualTo: sevenDaysAgoStr)
          .orderBy('date', descending: false)
          .get();
      
      // Process the data
      final sleepLogs = querySnapshot.docs.map((doc) => doc.data()).toList();
      
      if (sleepLogs.isEmpty) {
        setState(() {
          _isLoading = false;
          _feedbackMessage = "No sleep data recorded yet. Add your first sleep entry!";
        });
        return;
      }
      
      // Calculate average sleep duration
      int totalMinutes = 0;
      Map<String, int> dateToMinutes = {};
      
      for (var log in sleepLogs) {
        final durationMinutes = log['durationMinutes'] as int;
        final date = log['date'] as String;
        
        totalMinutes += durationMinutes;
        dateToMinutes[date] = durationMinutes;
      }
      
      final averageMinutes = totalMinutes ~/ sleepLogs.length;
      final hours = averageMinutes ~/ 60;
      final minutes = averageMinutes % 60;
      
      // Create chart spots
      List<FlSpot> spots = [];
      List<String> lastSevenDays = [];
      
      // Generate the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        lastSevenDays.add(dateStr);
      }
      
      // Plot data points
      for (int i = 0; i < lastSevenDays.length; i++) {
        final dateStr = lastSevenDays[i];
        final durationHours = dateToMinutes.containsKey(dateStr)
            ? dateToMinutes[dateStr]! / 60
            : 0.0;
        spots.add(FlSpot(i.toDouble(), durationHours));
      }
      
      // Generate feedback message
      String feedback;
      if (averageMinutes >= 420) { // 7 hours or more
        feedback = "You're hitting your daily sleep average goal of 7+ hours every night. Keep it up!";
      } else if (averageMinutes >= 360) { // 6 hours or more
        feedback = "You're getting close to the recommended 7+ hours of sleep. Try to go to bed a bit earlier.";
      } else {
        feedback = "You're sleeping less than recommended. Try to establish a consistent sleep schedule.";
      }
      
      // Update state
      setState(() {
        _isLoading = false;
        _averageSleepDuration = "$hours hrs ${minutes.toString().padLeft(2, '0')} min";
        _sleepSpots = spots;
        _feedbackMessage = feedback;
      });
    } catch (e) {
      print("Error loading sleep data: $e");
      setState(() {
        _isLoading = false;
        _feedbackMessage = "Error loading sleep data. Please try again later.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)))
        : SingleChildScrollView(
            child: Container(
              color: const Color(0xFFF9EDFF),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Sleep Tracker",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA764FF),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade100,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        _feedbackMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFA764FF), fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _averageSleepDuration,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA764FF),
                      ),
                    ),
                    Text(
                      "Average Sleep",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA764FF),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Last 7 Days",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA764FF),
                            ),
                          ),
                          SizedBox(height: 10),
                          _sleepSpots.isEmpty
                              ? Container(
                                  height: 150,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "No sleep data recorded yet",
                                    style: TextStyle(
                                      color: Color(0xFFA764FF),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 150,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 12,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey.withOpacity(0.3),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 22,
                                            getTitlesWidget: (value, meta) {
                                              final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                              if (value >= 0 && value < weekdays.length) {
                                                return Text(
                                                  weekdays[value.toInt()],
                                                  style: TextStyle(
                                                    color: Color(0xFFA764FF),
                                                    fontSize: 12,
                                                  ),
                                                );
                                              }
                                              return Text('');
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 28,
                                            getTitlesWidget: (value, meta) {
                                              if (value % 3 == 0) {
                                                return Text(
                                                  '${value.toInt()}h',
                                                  style: TextStyle(
                                                    color: Color(0xFFA764FF),
                                                    fontSize: 12,
                                                  ),
                                                );
                                              }
                                              return Text('');
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _sleepSpots,
                                          isCurved: true,
                                          color: Color(0xFFA764FF),
                                          barWidth: 3,
                                          isStrokeCapRound: true,
                                          dotData: FlDotData(show: true),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: Color(0xFFA764FF).withOpacity(0.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10),
                          Text(
                            "Hours of Sleep Per Night",
                            style: TextStyle(color: Color(0xFFA764FF), fontSize: 14),
                          ),
                          if (_sleepSpots.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFA764FF),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Your Sleep",
                                    style: TextStyle(
                                      color: Color(0xFFA764FF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                                Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SleepStatsScreen(),
                                ),
                              );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.purple.shade100,
                            elevation: 5,
                          ),
                          child: Text(
                            "In-Depth Stats",
                            style: TextStyle(color: Color(0xFFA764FF)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => MainLayout(
                                      currentIndex: 3, child: AddSleepScreen())),
                            );
                            // Refresh data when returning from the add screen
                            _loadSleepData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.purple.shade100,
                            elevation: 5,
                          ),
                          child: Text(
                            "+ Add Sleep",
                            style: TextStyle(color: Color(0xFFA764FF)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}