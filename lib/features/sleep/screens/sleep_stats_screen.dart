import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class SleepStatsScreen extends StatefulWidget {
  const SleepStatsScreen({Key? key}) : super(key: key);

  @override
  _SleepStatsScreenState createState() => _SleepStatsScreenState();
}

class _SleepStatsScreenState extends State<SleepStatsScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _sleepRecords = [];
  
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
      
      // Get sleep logs for the last 30 days, ordered by date (most recent first)
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(Duration(days: 30));
      final thirtyDaysAgoStr = DateFormat('yyyy-MM-dd').format(thirtyDaysAgo);
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleepLogs')
          .where('date', isGreaterThanOrEqualTo: thirtyDaysAgoStr)
          .orderBy('date', descending: true)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Process and format the data for display
      List<Map<String, dynamic>> formattedRecords = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Get date in readable format
        final date = data['date'] as String;
        final dateObj = DateFormat('yyyy-MM-dd').parse(date);
        final displayDate = DateFormat('EEEE, MMMM d, yyyy').format(dateObj);
        
        // Get sleep time and wake time
        Timestamp sleepTimestamp = data['sleepTime'] as Timestamp;
        Timestamp wakeTimestamp = data['wakeTime'] as Timestamp;
        final sleepTime = DateFormat('h:mm a').format(sleepTimestamp.toDate());
        final wakeTime = DateFormat('h:mm a').format(wakeTimestamp.toDate());
        
        // Format duration
        final durationMinutes = data['durationMinutes'] as int;
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes % 60;
        final duration = '$hours hrs ${minutes.toString().padLeft(2, '0')} min';
        
        // Get quality and notes
        final quality = data['quality'] as int;
        final notes = data['notes'] as String? ?? 'No notes added';
        
        formattedRecords.add({
          'date': displayDate,
          'sleepTime': sleepTime,
          'wakeTime': wakeTime,
          'duration': duration,
          'quality': quality,
          'notes': notes,
        });
      }
      
      setState(() {
        _sleepRecords = formattedRecords;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading sleep stats: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to build quality indicator with moon icons
  Widget _buildQualityIndicator(int quality) {
    return Row(
      children: List.generate(5, (index) {
        final rating = index + 1;
        return Icon(
          rating <= quality ? CupertinoIcons.moon_fill : CupertinoIcons.moon,
          size: 18,
          color: rating <= quality ? Color(0xFFA764FF) : Color(0xFFDDA7F6),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        title: const Text(
          'Sleep Stats',
          style: TextStyle(
            color: Color(0xFFDDA7F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)))
          : _sleepRecords.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.moon_zzz_fill,
                          color: Color(0xFFA764FF),
                          size: 60,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No sleep records found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA764FF),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Add your first sleep entry to start tracking your sleep patterns.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA764FF),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _sleepRecords.length,
                  itemBuilder: (context, index) {
                    final record = _sleepRecords[index];
                    return _buildSleepCard(record);
                  },
                ),
    );
  }

  Widget _buildSleepCard(Map<String, dynamic> record) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          // Header with date
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFA764FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  record['date'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Sleep details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sleep time and duration
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.bedtime, color: Color(0xFFDDA7F6), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${record['sleepTime']} → ${record['wakeTime']}",
                              style: TextStyle(
                                color: Color(0xFFA764FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Color(0xFFDDA7F6), size: 16),
                        SizedBox(width: 8),
                        Text(
                          record['duration'],
                          style: TextStyle(
                            color: Color(0xFFA764FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Sleep quality
                Row(
                  children: [
                    Text(
                      "Quality: ",
                      style: TextStyle(
                        color: Color(0xFFA764FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _buildQualityIndicator(record['quality']),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Notes
                if (record['notes'] != 'No notes added') ...[
                  Text(
                    "Notes:",
                    style: TextStyle(
                      color: Color(0xFFA764FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9EDFF).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record['notes'],
                      style: TextStyle(
                        color: Color(0xFFA764FF),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}