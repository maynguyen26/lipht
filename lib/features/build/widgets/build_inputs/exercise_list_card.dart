import 'package:flutter/material.dart';

import 'package:lipht/routes/routes.dart';

class ExerciseListCard extends StatefulWidget {
  final List<TextEditingController> controllers;

  final void Function() onSave;

  const ExerciseListCard({super.key, required this.controllers, required this.onSave});

  @override
  State<ExerciseListCard> createState() => _ExerciseListCardState();
}

class _ExerciseListCardState extends State<ExerciseListCard> {
  List<TextEditingController> get _controllers => widget.controllers;

  void _addNewCard() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeCard(int index) {
    setState(() {
      _controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Exercises",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA764FF),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220, 
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(_controllers.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
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
                        const Icon(Icons.fitness_center, color: Color(0xFFDDA7F6)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controllers[index],
                            decoration: const InputDecoration(
                              hintText: "e.g. Bench Press",
                              hintStyle: TextStyle(color: Color(0xFFDDA7F6)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                            ),
                            style: const TextStyle(
                              color: Color(0xFFA764FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFFA764FF)),
                          onPressed: () => _removeCard(index),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _addNewCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA764FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text(
                    "Add Exercise",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    print("Saving program...");
                    widget.onSave();
                    Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.build,
                    (route) => false,
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA764FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text(
                    "Save Program",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
