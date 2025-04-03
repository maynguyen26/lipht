import 'package:flutter/material.dart';
import 'action_button.dart';
import 'package:lipht/routes/routes.dart';

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ActionButton(text: "Choose a Program", onPressed: () {Navigator.pushNamed(context, Routes.chooseProgram);}),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ActionButton(text: "Build a Program", onPressed: () {Navigator.pushNamed(context, Routes.buildProgram);}),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ActionButton(text: "Empty Session", onPressed: () {Navigator.pushNamed(context, Routes.emptySession);}),
      ],
    );
  }
}