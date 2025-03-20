import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/routes/routes.dart';
import 'package:fl_chart/fl_chart.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFF9EDFF),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10 , horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Great Job!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA764FF), 
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade100,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "You're hitting your daily sleep average goal of 7+ hours every night. Keep it up!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFA764FF), fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "7 hrs 28 min",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA764FF),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Text(
                      "Your Stats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA764FF),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 5),
                                FlSpot(1, 6),
                                FlSpot(2, 5.5),
                                FlSpot(3, 6.5),
                                FlSpot(4, 7),
                                FlSpot(5, 7.2),
                                FlSpot(6, 7.5),
                              ],
                              isCurved: true,
                              color: Color(0xFFA764FF),
                              barWidth: 3,
                              isStrokeCapRound: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Average Sleep Per Night",
                      style: TextStyle(color: Color(0xFFA764FF), fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.sleepStats);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.purple.shade100,
                      elevation: 5,
                    ),
                    child: Text(
                      "In-Depth Stats",
                      style: TextStyle(color: Color(0xFFA764FF)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.addSleep);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.purple.shade100,
                      elevation: 5,
                    ),
                    child: Text(
                      "+ Add Sleep",
                      style: TextStyle(color: Color(0xFFA764FF)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
