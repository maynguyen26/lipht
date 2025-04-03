import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';

class ChooseProgramScreen extends StatelessWidget {
  const ChooseProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFFF9EDFF),
      body: Center(
        child: user == null
            ? const Text("Please log in to view saved programs.")
            : const Text(
                "This is where saved programs will be listed.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFA764FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
