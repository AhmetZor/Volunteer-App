import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'Home/home.dart';
import 'Profile/profile.dart';
import 'Notifications/notification.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 1; // Default to HomeScreen

  final List<Widget> _screens = [
    ProfileScreen(),
    HomeScreen(),
    NotificationScreen(),
  ];

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the currently selected screen
      bottomNavigationBar: CircleNavBar(
        activeIndex: _currentIndex,
        activeIcons: [
          GestureDetector(
            onTap: () => _onNavBarTapped(0), // Profile icon
            child: Icon(Icons.person, color: Colors.deepPurple),
          ),
          GestureDetector(
            onTap: () => _onNavBarTapped(1), // Home icon
            child: Icon(Icons.home, color: Colors.deepPurple),
          ),
          GestureDetector(
            onTap: () => _onNavBarTapped(2), // Notifications icon
            child: Icon(Icons.notifications, color: Colors.deepPurple),
          ),
        ],
        inactiveIcons: [
          GestureDetector(
            onTap: () => _onNavBarTapped(0), // Profile text
            child: const Text("Profile"),
          ),
          GestureDetector(
            onTap: () => _onNavBarTapped(1), // Home text
            child: const Text("Home"),
          ),
          GestureDetector(
            onTap: () => _onNavBarTapped(2), // Notifications text
            child: const Text("Notifications"),
          ),
        ],
        color: Colors.white,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Colors.deepPurple,
        circleShadowColor: Colors.deepPurple,
        elevation: 10,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
        circleGradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
      ),
    );
  }
}
