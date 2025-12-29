import 'package:flutter/material.dart';

class MyRouteOwned extends StatefulWidget {
  const MyRouteOwned({super.key});

  @override
  State<MyRouteOwned> createState() => _MyRouteOwnedState();
}

class _MyRouteOwnedState extends State<MyRouteOwned> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Routes'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('My Routes will be displayed here.'),
      ),
    );
  }
}