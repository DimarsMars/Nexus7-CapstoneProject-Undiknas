import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/journeys_item.png',
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'Gambar tidak ditemukan',
              style: TextStyle(color: Colors.red),
            );
          },
        ),
      ),
    );
  }
}
