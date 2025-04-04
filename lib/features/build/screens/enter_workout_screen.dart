import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic> program;

  const EnterWorkoutScreen({super.key, required this.program});

  @override
  State<EnterWorkoutScreen> createState() => _EnterWorkoutScreenState();
}

class _EnterWorkoutScreenState extends State<EnterWorkoutScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 18, minute: 0);

  final Map<String, List<Map<String, String>>> _exerciseSets = {};

  @override
  void initState() {
    super.initState();
    for (var exercise in widget.program['exercises']) {
      _exerciseSets[exercise] = [];
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addSet(String exercise) {
    setState(() {
      _exerciseSets[exercise]!.add({'weight': '', 'reps': '', 'rpe': ''});
    });
  }

  void _removeSet(String exercise, int index) {
    setState(() {
      _exerciseSets[exercise]!.removeAt(index);
    });
  }

  Future<void> _submitWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final workoutData = {
      'programName': widget.program['name'],
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'startTime': _startTime.format(context),
      'endTime': _endTime.format(context),
      'exercises': _exerciseSets,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workoutLogs')
        .add(workoutData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final programName = widget.program['name'] ?? 'Workout';
    final exercises = widget.program['exercises'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFDDA7F6)),
        title: Text(
          programName,
          style: const TextStyle(
            color: Color(0xFFDDA7F6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoRow("Date", DateFormat('MMM dd, yyyy').format(_selectedDate), Icons.calendar_today, () => _selectDate()),
          const SizedBox(height: 10),
          _infoRow("Start Time", _startTime.format(context), Icons.access_time, () => _selectTime(isStart: true)),
          const SizedBox(height: 10),
          _infoRow("End Time", _endTime.format(context), Icons.access_time_filled, () => _selectTime(isStart: false)),
          const SizedBox(height: 20),

          ...exercises.map((exercise) => _exerciseCard(exercise)),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA764FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Submit Workout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFA764FF), size: 20), // <-- updated icon color
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA764FF), // <-- label text color
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA764FF), // <-- actual value color
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _exerciseCard(String name) {
    final sets = _exerciseSets[name]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.purple.shade50, blurRadius: 4, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFA764FF),
                fontSize: 16,
              )),
          const SizedBox(height: 12),
          ...sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Text('='),
                  const SizedBox(width: 8),
                  _inputField("Weight", set['weight']!, (val) => set['weight'] = val),
                  const SizedBox(width: 8),
                  const Text('x'),
                  const SizedBox(width: 8),
                  _inputField("Reps", set['reps']!, (val) => set['reps'] = val),
                  const SizedBox(width: 8),
                  const Text('@'),
                  const SizedBox(width: 8),
                  _inputField("RPE", set['rpe']!, (val) => set['rpe'] = val),
                  IconButton(
                    onPressed: () => _removeSet(name, index),
                    icon: const Icon(Icons.close, color: Color(0xFFDDA7F6)),
                  )
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () => _addSet(name),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA764FF),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // this won't change the button text color directly
                ),
              ),
              child: const Text(
                "Add Set",
                style: TextStyle(
                  color: Colors.white, // actual text color here
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _inputField(String hint, String value, Function(String) onChanged) {
    return Expanded(
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFDDA7F6)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDA7F6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFA764FF)),
          ),
        ),
      ),
    );
  }
}
