import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart' as app_auth;
import 'package:lipht/features/build/widgets/build_inputs/program_name_card.dart';
import 'package:lipht/features/build/widgets/build_inputs/workout_days_selector.dart';
import 'package:lipht/features/build/widgets/build_inputs/exercise_list_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BuildProgramScreen extends StatefulWidget {
  const BuildProgramScreen({super.key});

  @override
  State<BuildProgramScreen> createState() => _BuildProgramScreenState();
}

class _BuildProgramScreenState extends State<BuildProgramScreen> {
  final TextEditingController _programNameController = TextEditingController();
  final List<TextEditingController> _exerciseControllers = []; // NEW
  Set<String> _selectedDays = {};


  Future<void> _saveProgram() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to save a program.")),
      );
      return;
    }

    final programName = _programNameController.text.trim();
    final exercises = _exerciseControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (programName.isEmpty || exercises.isEmpty || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('programs')
          .add({
        'name': programName,
        'days': _selectedDays.toList(),
        'exercises': exercises,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Program saved!")),
      );

      _programNameController.clear();
      _exerciseControllers.clear();
      _selectedDays.clear();
      setState(() {});
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save program.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<app_auth.AuthProvider>(context);

    final user = authProvider.user;

    return Scaffold(

      backgroundColor: const Color (0xFFF9EDFF),

      appBar: AppBar(

        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        title: const Text(
          'Build New Program',

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

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgramNameCard(controller: _programNameController),

            const SizedBox(height: 5),

            WorkoutDaysSelector(
              selectedDays: _selectedDays,
              onChanged: (updatedDays) {
                setState(() {
                  _selectedDays = updatedDays;
                });
              }, 
            ),

            const SizedBox(height: 5),

            ExerciseListCard(  controllers: _exerciseControllers, onSave: _saveProgram,),

          ],)


      )



    );
  }
}