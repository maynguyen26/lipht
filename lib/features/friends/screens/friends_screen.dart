import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8FF),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header

            SizedBox(height: 20),

            // Category Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryIcon(Icons.build, "build"),
                SizedBox(width: 20),
                _buildCategoryIcon(Icons.local_gas_station, "fuel"),
                SizedBox(width: 20),
                _buildCategoryIcon(Icons.nights_stay, "sleep"),
              ],
            ),
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
                  hintText: "Benchpress",
                  hintStyle: TextStyle(color: Color(0xFF9D76C1)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: Icon(Icons.search, color: Color(0xFF9D76C1)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Search Results Header
            Text(
              "Results for benchpress:",
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
                  _buildUserRow("Jerry", "275lbs"),
                  _buildUserRow("Nicolette", "1000g"),
                  _buildUserRow("May", "85g"),
                  _buildUserRow("Amir", "55g"),
                  _buildUserRow("Ivan", "300g"),
                  _buildUserRow("Majd", "7500lbs")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Icon Widget
  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF9D76C1), size: 32),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Color(0xFF9D76C1))),
      ],
    );
  }

  // User Row Widget
  Widget _buildUserRow(String name, String weight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Color(0xFFB89FC9)),
              SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(fontSize: 16, color: Color(0xFF9D76C1)),
              ),
            ],
          ),
          Text(
            weight,
            style: TextStyle(fontSize: 16, color: Color(0xFF9D76C1)),
          ),
        ],
      ),
    );
  }
}
