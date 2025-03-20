import 'package:flutter/material.dart';

class NavigationBarRoutes {
  static const String home = '/home';
  static const String workout = '/build'; // Using your build route for workout
  static const String nutrition = '/fuel';
  static const String sleep = '/sleep';
  static const String social = '/friends';
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9EDFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF9EDFF),
          selectedItemColor: const Color(0xFFA764FF),
          unselectedItemColor: const Color(0xFFCEA9FF),
          elevation: 0,
          iconSize: 28, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman_outlined),
              activeIcon: Icon(Icons.handyman),
              label: 'Build',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_gas_station_outlined),
              activeIcon: Icon(Icons.local_gas_station),
              label: 'Fuel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.nightlight_outlined),
              activeIcon: Icon(Icons.nightlight),
              label: 'Sleep',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Friends',
            ),
          ],
        ),
      ),
    );
  }
}