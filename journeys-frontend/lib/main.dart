import 'package:flutter/material.dart';
import 'package:journeys/router/app_router.dart';
import 'package:journeys/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
  title: 'Journeys',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  routerConfig: appRouter,
);
  }
}