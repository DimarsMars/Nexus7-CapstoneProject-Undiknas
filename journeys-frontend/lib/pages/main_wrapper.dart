import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/theme/app_theme.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;

    if (location.startsWith('/home') || location.startsWith('/categories')) {
      currentIndex = 0;
    } else if (location.startsWith('/explore')) {
      currentIndex = 1;
    } else if (location.startsWith('/history')) {
      currentIndex = 2;
    } else if (location.startsWith('/traveller')) {
      currentIndex = 3;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          backgroundColor: AppColors.background,
          onDestinationSelected: (int index) {
            switch (index) {
              case 0: context.go('/home'); break;
              case 1: context.go('/explore'); break;
              case 2: context.go('/history'); break;
              case 3: context.go('/traveller'); break;
            }
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              selectedIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
