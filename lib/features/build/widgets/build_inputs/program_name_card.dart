import 'package:flutter/material.dart';

class ProgramNameCard extends StatelessWidget {
  final TextEditingController controller;

  const ProgramNameCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade50,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFFDDA7F6), size: 20),
          const SizedBox(width: 10),
          const Text(
            "Program Name:",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA764FF),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 160,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: "e.g. Leg Day",
                hintStyle: TextStyle(
                  color: Color(0xFFDDA7F6),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                color: Color(0xFFA764FF),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
