import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddSleepScreen extends StatefulWidget {
  const AddSleepScreen({Key? key}) : super(key: key);

  @override
  _AddSleepScreenState createState() => _AddSleepScreenState();
}

class _AddSleepScreenState extends State<AddSleepScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Selected date (default to today)
  DateTime _selectedDate = DateTime.now();
  
  // Sleep time (default to 11:30 PM)
  TimeOfDay _sleepTime = TimeOfDay(hour: 23, minute: 30);
  
  // Wake time (default to 7:30 AM)
  TimeOfDay _wakeTime = TimeOfDay(hour: 7, minute: 30);
  
  // Sleep quality rating (1-5)
  int _sleepQuality = 3;
  
  // Notes about sleep
  final TextEditingController _notesController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Function to calculate sleep duration in minutes
  int _calculateSleepDuration() {
    // Convert sleep time to minutes from midnight
    int sleepMinutes = _sleepTime.hour * 60 + _sleepTime.minute;
    
    // Convert wake time to minutes from midnight
    int wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    
    // Adjust if sleep is before midnight and wake is after
    if (sleepMinutes > wakeMinutes) {
      return (24 * 60 - sleepMinutes) + wakeMinutes;
    } else {
      return wakeMinutes - sleepMinutes;
    }
  }
  
  // Function to format duration in hours and minutes
  String _formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    return '$hours hrs ${mins.toString().padLeft(2, '0')} min';
  }

  // Function to save sleep data to Firebase
  Future<void> _saveSleepData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to save sleep data')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Calculate sleep start and end times as DateTime objects
      final sleepDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _sleepTime.hour,
        _sleepTime.minute,
      );
      
      // For wake time, if it's earlier than sleep time, it's the next day
      DateTime wakeDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _wakeTime.hour,
        _wakeTime.minute,
      );
      
      if (_wakeTime.hour < _sleepTime.hour) {
        wakeDateTime = wakeDateTime.add(Duration(days: 1));
      }
      
      // Calculate duration in minutes
      final durationMinutes = _calculateSleepDuration();
      
      // Format date string for Firebase
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // Save to Firebase
      await _firestore.collection('users').doc(user.uid).collection('sleepLogs').add({
        'date': dateString,
        'sleepTime': Timestamp.fromDate(sleepDateTime),
        'wakeTime': Timestamp.fromDate(wakeDateTime),
        'durationMinutes': durationMinutes,
        'quality': _sleepQuality,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sleep data saved successfully')),
      );
      
      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving sleep data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save sleep data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // Function to select sleep time
  Future<void> _selectSleepTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sleepTime,
    );
    if (picked != null && picked != _sleepTime) {
      setState(() {
        _sleepTime = picked;
      });
    }
  }
  
  // Function to select wake time
  Future<void> _selectWakeTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeTime,
    );
    if (picked != null && picked != _wakeTime) {
      setState(() {
        _wakeTime = picked;
      });
    }
  }

  @override
  Widget build (BuildContext context){
    // Calculate duration for display
    final durationMinutes = _calculateSleepDuration();
    final durationText = _formatDuration(durationMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        title: const Text(
          'Sleep Details',
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
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: _infoCard(
                  title: "Night of:",
                  content: DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  icon: Icons.calendar_today,
                ),
              ),
              
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Color(0xFFDDA7F6), size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Sleep Time:",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => _selectSleepTime(context),
                          child: Text(
                            _sleepTime.format(context),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Color(0xFFDDA7F6), size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Wake Time:",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => _selectWakeTime(context),
                          child: Text(
                            _wakeTime.format(context),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.timelapse, color: Color(0xFFDDA7F6), size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Duration:",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                        ),
                        Spacer(),
                        Text(
                          durationText,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rate your sleep
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sleep Quality Rating",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _sleepQuality = rating;
                            });
                          },
                          child: Icon(
                            _sleepQuality >= rating ? CupertinoIcons.moon_fill : CupertinoIcons.moon,
                            size: 30,
                            color: _sleepQuality >= rating ? Color(0xFFA764FF) : Color(0xFFDDA7F6),
                          ),
                        );
                      }),
                    ),
                  ],
                )
              ),

              // Notes
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Notes",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "How did you sleep? Any factors that affected your sleep?",
                        hintStyle: TextStyle(color: Color(0xFFDDA7F6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFDDA7F6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFA764FF)),
                        ),
                      ),
                    ),
                  ],
                )
              ),

              Container(
                margin: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSleepData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA764FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Add Sleep",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required String content, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFDDA7F6), size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
          ),
          const Spacer(),
          Text(
            content,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFA764FF)),
          ),
        ],
      )
    );
  }
}