import 'package:flutter/material.dart';
import 'package:lipht/features/build/widgets/exercise_tracking/exercise_tracking_card.dart';
import 'package:lipht/features/build/widgets/pie_chart_metrics/pie_chart_card.dart';
import 'package:lipht/features/build/widgets/action_buttons/action_buttons_section.dart';
import 'package:lipht/features/build/widgets/exercise_tracking/weekly_weight_chart.dart';

class BuildScreen extends StatelessWidget {
  const BuildScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // Exercise tracking section
            ExerciseTrackingCard(),
            
            SizedBox(height: 20),
            
            WeeklyWeightChart(),
            
            SizedBox(height: 20),
            
            // Action buttons
            ActionButtonsSection(),
          ],
        ),
      ),
    );
  }
}