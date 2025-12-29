import 'package:flutter/material.dart';

class MyRatingOwned extends StatefulWidget {
  const MyRatingOwned({super.key});

  @override
  State<MyRatingOwned> createState() => _MyRatingOwnedState();
}

class _MyRatingOwnedState extends State<MyRatingOwned> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Ratings'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('My Ratings will be displayed here.'),
      ),
    );
  }
}