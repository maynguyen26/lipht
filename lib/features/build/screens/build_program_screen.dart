import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/routes/routes.dart';
import 'package:lipht/features/build/widgets/build_inputs/program_name_card.dart';
import 'package:lipht/features/build/widgets/build_inputs/workout_days_selector.dart';


class BuildProgramScreen extends StatefulWidget {
  const BuildProgramScreen({super.key});

  @override
  State<BuildProgramScreen> createState() => _BuildProgramScreenState();
}

class _BuildProgramScreenState extends State<BuildProgramScreen> {
  final TextEditingController _programNameController = TextEditingController();
  Set<String> _selectedDays = {};

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(

      backgroundColor: const Color (0xFFF9EDFF),

      appBar: AppBar(

        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        title: const Text(
          'Build a New Program',

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

      body: Padding(
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


          ],)


      )



    );
  }
}