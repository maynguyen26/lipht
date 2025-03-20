import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final greeting = user != null ? 'Hi, ${user.firstName}!' : 'Welcome!';

    return Container(
      color: const Color(0xFFF9EDFF),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9747FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
