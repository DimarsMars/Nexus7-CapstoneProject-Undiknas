import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/theme/app_theme.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Determine the current index based on the route location
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/home')) {
      currentIndex = 0;
    } else if (location.startsWith('/explore')) {
      currentIndex = 1;
    } else if (location.startsWith('/history')) { // Assuming a /history route for the 3rd tab
      currentIndex = 2;
    } else if (location.startsWith('/traveller')) {
      currentIndex = 3;
    }

    return Scaffold(
      body: child, // Display the child route here
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              break;
            case 2:
              break;
            case 3:
              break;
          }
        },
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.accent.withOpacity(0.2),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined), // Placeholder for history/itinerary
            selectedIcon: Icon(Icons.list_alt),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile', // Or Social
          ),
        ],
      ),
    );
  }
}
