import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/insight/insight_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Main bottom navigation bar that switches between app sections.
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  /// Screens used inside the navigation
  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    InsightScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Keeps all pages alive using IndexedStack
      body: IndexedStack(index: _currentIndex, children: _screens),

      /// Styled bottom navigation container (shadow + minimal white card)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // removed radius
          // borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),

          /// Navigation items
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
            _buildNavItem(
              Icons.photo_library_outlined,
              Icons.photo_library_rounded,
              'Library',
              1,
            ),
            _buildNavItem(
              Icons.insights_outlined,
              Icons.insights_rounded,
              'Insight',
              2,
            ),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  /// Builds each navigation bar
  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon: Icon(activeIcon, size: 26, color: Colors.deepPurple),
      label: label,
    );
  }
}
