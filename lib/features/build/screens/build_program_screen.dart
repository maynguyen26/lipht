import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/routes/routes.dart';

class BuildProgramScreen extends StatelessWidget {
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
          'Build Program Screen',
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
    );
  }
}