import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryIcon(Icons.build, "build"),
                  const SizedBox(width: 20),
                  _buildCategoryIcon(Icons.local_gas_station, "fuel"),
                  const SizedBox(width: 20),
                  _buildCategoryIcon(Icons.nights_stay, "sleep"),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA764FF)),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Benchpress",
                    hintStyle: TextStyle(color: Color(0xFFA764FF)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    suffixIcon: Icon(Icons.search, color: Color(0xFFA764FF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Results for benchpress:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA764FF),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    _buildUserRow("Jerry", "275lbs"),
                    _buildUserRow("Nicolette", "100lbs"),
                    _buildUserRow("May", "85lbs"),
                    _buildUserRow("Amir", "55lbs"),
                    _buildUserRow("Ivan", "20lbs"),
                    _buildUserRow("Majd", "750lbs")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFA764FF), size: 32),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Color(0xFFA764FF))),
      ],
    );
  }

  Widget _buildUserRow(String name, String weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFFF3DBFF)),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(fontSize: 16, color: Color(0xFFA764FF)),
              ),
            ],
          ),
          Text(
            weight,
            style: const TextStyle(fontSize: 16, color: Color(0xFFA764FF)),
          ),
        ],
      ),
    );
  }
}
