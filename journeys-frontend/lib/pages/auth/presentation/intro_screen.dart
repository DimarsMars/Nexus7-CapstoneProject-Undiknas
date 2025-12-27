import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart'; // Hapus/Comment jika belum pakai MaterialApp.router
import 'dart:async';
import '../../../theme/app_theme.dart';
import 'login_screen.dart'; // Pastikan import ini ada

enum _IntroState { blank, logoVisible, welcomeVisible }

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  _IntroState _currentState = _IntroState.blank;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    // 1. Munculkan Logo setelah 0.5 detik
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _currentState = _IntroState.logoVisible);
      }
    });

    // 2. Munculkan Teks Welcome setelah 2 detik
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _currentState = _IntroState.welcomeVisible);
      }
    });

    // 3. PINDAH OTOMATIS ke Login setelah 4 detik
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    // Menggunakan Navigator biasa karena main.dart kamu belum mendukung GoRouter
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center( // GestureDetector dihapus agar tidak perlu diklik
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _currentState != _IntroState.blank ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Image.asset('assets/icons/logo.png', height: 350),
            ),
            const SizedBox(height: 40),
            AnimatedOpacity(
              opacity: _currentState == _IntroState.welcomeVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  Text(
                    'WELCOME',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Teks "klik layar" bisa dihapus atau diganti
                  Text(
                    'Memuat aplikasi...', 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}