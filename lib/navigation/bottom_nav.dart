import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/insight_screen.dart';
import '../screens/profile/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    InsightScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.photo_library_outlined, Icons.photo_library, 'Library', 1),
            _buildNavItem(Icons.insights_outlined, Icons.insights, 'Insight', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 2),
          if (_currentIndex == index)
            Container(
              width: 20,
              height: 2,
              color: Colors.deepPurple,
            ),
        ],
      ),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(activeIcon),
          const SizedBox(height: 2),
          Container(
            width: 20,
            height: 2,
            color: Colors.deepPurple,
          ),
        ],
      ),
      label: label,
    );
  }
}
