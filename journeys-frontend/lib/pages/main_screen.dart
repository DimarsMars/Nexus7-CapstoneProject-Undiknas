import 'package:flutter/material.dart';
import 'package:journeys/pages/history_screen.dart';
import 'route_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const RouteScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,

        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/home_inactive.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/home_active.png',
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/route_inactive.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/route_active.png',
              width: 24,
              height: 24,
            ),
            label: 'Route',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/history_inactive.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/history_active.png',
              width: 24,
              height: 24,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/profile_inactive.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/icons/profile_active.png',
              width: 24,
              height: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}