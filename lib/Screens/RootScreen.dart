import 'package:flutter/material.dart';
import 'Home/home.dart';
import 'Profile/profile.dart';
import 'Map/map_screen.dart';
import 'Camera/camera_screen.dart';
import 'Socials/socials_screen.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0; // Default to HomeScreen

  final List<Widget> _screens = [
    HomeScreen(),
    CameraScreen(),
    EventMap(),
    SocialsScreen(),
    ProfileScreen(),
  ];

  void _onNavBarTapped(int index) {
    if (index != 2) { // Center button (Map) remains static
      setState(() {
        _currentIndex = index;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EventMap()), // Open Map screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return
      Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, -2),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            isSelected: currentIndex == 0,
            onTap: onTap,
          ),
          _buildNavItem(
            icon: Icons.camera_alt,
            label: 'Camera',
            index: 1,
            isSelected: currentIndex == 1,
            onTap: onTap,
          ),
          _buildMapButton(onTap), // Center static map button
          _buildNavItem(
            icon: Icons.group,
            label: 'Socials',
            index: 3,
            isSelected: currentIndex == 3,
            onTap: onTap,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            index: 4,
            isSelected: currentIndex == 4,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required Function(int) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isSelected ? 8 : 0,
            width: isSelected ? 8 : 0,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 6), // Adjusted spacing
          Icon(
            icon,
            color: isSelected ? Colors.deepPurpleAccent : Colors.grey[600],
            size: 28, // Increased icon size
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.deepPurpleAccent : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(Function(int) onTap) {
    return Transform.translate(
      offset: Offset(0, -20), // Adjust the elevation height
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withOpacity(0.4),
                spreadRadius: 4,
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.map,
            color: Colors.white,
            size: 42, // Larger icon size
          ),
        ),
      ),
    );
  }
}
