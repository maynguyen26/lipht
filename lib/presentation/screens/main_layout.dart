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

class MainLayout extends StatefulWidget {
  final int currentIndex;
  final Widget? child; // Optional child widget to display

  const MainLayout({
    Key? key,
    this.currentIndex = 0, // Default to home tab
    this.child,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  // Create separate variables to track the build tab content
  late Widget _buildTabContent;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;

    // Initialize the build tab content
    _buildTabContent = widget.child ?? BuildScreen();
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update current index if changed
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _currentIndex = widget.currentIndex;
      });
    }

    // Update build tab content if the child changed
    if (oldWidget.child != widget.child && _currentIndex == 1) {
      setState(() {
        _buildTabContent = widget.child ?? BuildScreen();
      });
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index && index == 1 && widget.child != null) {
      // If we tap the Build tab while showing a child, go back to main build screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainLayout(currentIndex: 1),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

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
        title: const Text(
          'LIPHT',
          style: TextStyle(
            color: Color(0xFFDDA7F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, size: 30),
              color: const Color(0xFFDDA7F6),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.settings);
                debugPrint('Settings button pressed');
              },
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
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
