import 'package:flutter/material.dart';
// Pastikan nama package sesuai dengan pubspec.yaml Anda
import 'pages/MainScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journeys',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        // Tema dasar aplikasi Anda
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        // Atur tema AppBar agar konsisten
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0, // Tanpa bayangan
          foregroundColor: Colors.black87, // Warna teks dan ikon di AppBar
        ),
      ),
      // Langsung arahkan ke MainScreen sebagai halaman utama
      home: const MainScreen(),
    );
  }
}