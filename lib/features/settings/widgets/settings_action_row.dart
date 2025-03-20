import 'package:flutter/material.dart';

class SettingsActionRow extends StatelessWidget {
  final String label;
  final Color labelColor;
  final VoidCallback onTap;
  final IconData? icon;

  const SettingsActionRow({
    Key? key,
    required this.label,
    this.labelColor = const Color(0xFF9370DB),
    required this.onTap,
    this.icon = Icons.chevron_right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              icon,
              color: labelColor,
            ),
          ],
        ),
      ),
    );
  }
}