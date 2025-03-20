import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF), // Matching app background color
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFFDDA7F6), // Title color set to DDA7F6
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6), // Back button color
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFA764FF), // Purple text color to match app theme
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
