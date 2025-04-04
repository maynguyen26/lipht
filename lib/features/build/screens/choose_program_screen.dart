import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lipht/features/build/widgets/choose_inputs/program_card.dart';

class ChooseProgramScreen extends StatelessWidget {
  const ChooseProgramScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchPrograms() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('programs')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
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
          'Choose Program',
          style: TextStyle(
            color: Color(0xFFDDA7F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPrograms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No programs have been saved yet.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFA764FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final programs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              return ProgramCard(
                program: programs[index],
                onSelect: () {
                  // TODO: define what happens when the user selects this program
                  // For now, you can just log or navigate
                  print("Selected program: ${programs[index]['name']}");
                  
                  // Example if you want to navigate:
                  // Navigator.pushNamed(context, '/enterWorkout', arguments: programs[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
