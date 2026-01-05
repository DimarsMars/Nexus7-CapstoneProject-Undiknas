import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/pages/auth/presentation/signup_screen.dart';
import 'package:journeys/pages/explore/presentation/explore_screen.dart';
import 'package:journeys/pages/home_screen.dart';
import 'package:journeys/pages/categories_screen.dart';
import 'package:journeys/pages/plan_opened_screen.dart';
import 'package:journeys/pages/review/presentation/give_review_screen.dart';
import 'package:journeys/pages/review/presentation/place_detail_screen.dart';
import 'package:journeys/pages/review/presentation/traveller_screen.dart';
import 'package:journeys/pages/review/presentation/trip_review_screen.dart';
import 'package:journeys/pages/main_wrapper.dart';
import 'package:journeys/pages/review/presentation/traveller_detail_screen.dart';
import 'package:journeys/pages/profile/profile_screen.dart';
import 'package:journeys/pages/history_screen.dart';

import '../../pages/auth/presentation/intro_screen.dart';
import '../../pages/auth/presentation/login_screen.dart';

// This key is used to navigate to the shell's content area.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/intro',
  routes: <RouteBase>[
    // Auth routes (outside the shell)
    GoRoute(
      path: '/intro',
      builder: (BuildContext context, GoRouterState state) {
        return const IntroScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignupScreen();
      },
    ),

    // ShellRoute for main navigation
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainWrapper(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/explore',
          builder: (BuildContext context, GoRouterState state) {
            return const ExploreScreen();
          },
        ),
        GoRoute(
          path: '/traveller',
          builder: (BuildContext context, GoRouterState state) {
            return const TravellerScreen();
          },
        ),
        // Categories dimasukkan ke dalam ShellRoute agar Nav Bar muncul
        GoRoute(
          path: '/categories',
          builder: (BuildContext context, GoRouterState state) {
            return const CategoriesScreen();
          },
        ),
         GoRoute(
  path: '/plan-opened/:id',
  builder: (context, state) {
    final planId = int.parse(state.pathParameters['id']!);
    return PlanOpenedScreen(planId: planId);
  },
),


      GoRoute(
  path: '/place-detail',
  builder: (BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;
    final routeId = extra?['routeId'] as int?;

    if (routeId == null) {
      return const Scaffold(body: Center(child: Text('Route ID not provided')));
    }

    return PlaceDetailScreen(routeId: routeId);
  },
),

        GoRoute(
  path: '/traveller-detail',
  builder: (BuildContext context, GoRouterState state) {
    final extra = state.extra as Map<String, dynamic>?;

    final userId = extra?['userId'] as int?;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User ID not provided')),
      );
    }

    return TravellerDetailScreen(userId: userId);
  },
),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: '/history',
          builder: (BuildContext context, GoRouterState state) {
            return const HistoryScreen();
          },
        ),
      ],
    ),

    // Other top-level routes (details, forms, etc. - Tanpa Nav Bar)
    GoRoute(
      path: '/give-review',
      builder: (BuildContext context, GoRouterState state) {
        return const GiveReviewScreen();
      },
    ),
    GoRoute(
      path: '/review-summary',
      builder: (BuildContext context, GoRouterState state) {
        return const TripReviewScreen();
      },
    ),
  ],
);