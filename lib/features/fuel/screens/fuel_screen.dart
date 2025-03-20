import 'package:flutter/material.dart';

class FuelScreen extends StatelessWidget {
  const FuelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header

            SizedBox(height: 20),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF9D76C1)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "salmon",
                  hintStyle: TextStyle(color: Color(0xFF9D76C1)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: Icon(Icons.search, color: Color(0xFF9D76C1)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // AI Meal Analysis button
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFA764FF), // Purple color from your border
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Add your button action here
                    print("AI Meal Analysis button pressed");
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "AI Meal Analysis",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.camera_alt, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Search Results Header
            Text(
              "Results for salmon:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9D76C1),
              ),
            ),
            SizedBox(height: 10),

            // Search Results List
            Expanded(
              child: ListView(
                children: [
                  _buildMealItemRow("Grilled Salmon", "232 cals"),
                  _buildMealItemRow("Salmon Sushi", "200 cals"),
                  _buildMealItemRow("Salmon Tacos", "300 cals"),
                  _buildMealItemRow("Smoked Salmon Bagel", "410 cals"),
                  _buildMealItemRow("Salmon Poke Bowl", "450 cals"),
                  _buildMealItemRow("Honey Glazed Salmon", "275 cals"),
                  _buildMealItemRow("Salmon Ceviche", "180 cals"),
                  _buildMealItemRow("Teriyaki Salmon", "320 cals"),
                  _buildMealItemRow("Salmon Avocado Toast", "385 cals"),
                  _buildMealItemRow("Blackened Salmon", "250 cals"),
                  _buildMealItemRow("Lemon Dill Salmon", "220 cals"),
                  _buildMealItemRow("Salmon Salad", "290 cals"),
                  _buildMealItemRow("Cajun Salmon", "265 cals"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Meal Item Row Widget
  Widget _buildMealItemRow(String mealName, String calories) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF879FFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Left section with meal info
            Expanded(
              child: Text(
                "$mealName ($calories)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),

            // Right icon
            Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
