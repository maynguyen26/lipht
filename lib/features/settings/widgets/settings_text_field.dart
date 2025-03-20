import 'package:flutter/material.dart';

class SettingsTextField extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SettingsTextField({
    Key? key,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFAA77EE)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9370DB),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}