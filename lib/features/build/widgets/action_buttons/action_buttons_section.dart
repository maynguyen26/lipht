import 'package:flutter/material.dart';
import 'action_button.dart';

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: ActionButton(text: "Choose Program"),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ActionButton(text: "Build a Program"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ActionButton(text: "Empty Session"),
      ],
    );
  }
}