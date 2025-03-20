import 'package:flutter/material.dart';
import 'package:lipht/features/friends/screens/friends_screen.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/auth_provider.dart';
import 'package:lipht/presentation/widgets/bottom_nav_bar.dart';
import 'package:lipht/features/home/screens/home_screen.dart';
import 'package:lipht/features/build/screens/build_screen.dart';
import 'package:lipht/features/sleep/screens/sleep_screen.dart';
import 'package:lipht/routes/routes.dart';
// Import other screen files when you create them
// import 'package:lipht/features/fuel/screens/fuel_screen.dart';
// import 'package:lipht/features/sleep/screens/sleep_screen.dart';
// import 'package:lipht/features/friends/screens/friends_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int currentIndex;
  final Widget? child; // Optional child widget to display

  const SettingsScreen({
    Key? key,
    this.currentIndex = 0, // Default to home tab
    this.child,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9EDFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 30,
        toolbarHeight: 80,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LIPHT',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Color(0xFFDDA7F6),
                fontWeight: FontWeight.w800,
              ),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159), 
              child: Icon(
                Icons.fitness_center,
                color: const Color(0xFFDDA7F6),
                grade: 900, 
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFDDA7F6), // Back button color
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Create a list of screens with the current content
    final screens = [
      HomeScreen(),
      _buildBuildTabWithAnimation(),
      Center(child: Text('Fuel Screen')),
      SleepScreen(),
      FriendsScreen(),
    ];

    // Use IndexedStack to maintain state across tabs
    return IndexedStack(
      index: _currentIndex,
      children: screens,
    );
  }

  // This method builds the Build tab with animation when needed
  Widget _buildBuildTabWithAnimation() {
    // The key part: Use AnimatedSwitcher with a key based on the child's identity
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Slide from right animation
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      // Key is crucial for AnimatedSwitcher to detect changes
      child: KeyedSubtree(
        key: ValueKey(_buildTabContent.hashCode),
        child: _buildTabContent,
      ),
    );
  }
}

