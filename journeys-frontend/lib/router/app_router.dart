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
      ],
    ),

    // Other top-level routes (details, forms, etc.)
    GoRoute(
      path: '/plan-detail',
      builder: (BuildContext context, GoRouterState state) {
        return const PlanOpenedScreen();
      },
    ),
    GoRoute(
      path: '/categories',
      builder: (BuildContext context, GoRouterState state) {
        return const CategoriesScreen();
      },
    ),
    GoRoute(
      path: '/place-detail',
      builder: (BuildContext context, GoRouterState state) {
        return const PlaceDetailScreen();
      },
    ),
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