import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe9ebee),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Profile'),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),

                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 60,
                      ),
                      SizedBox(height: 30),

                      Text(
                        'Name',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      Text(
                        'Alexander Supri',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        'Rank\'s',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      Text(
                        'Adventurer',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C314A),
                          ),
                      ),

                      SizedBox(height: 40),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:90.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: Color(0xFF1C314A),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                          ),
                          child: Text(
                            'Edit Profile',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      _buildMenuItem(context, 'Languages'),
                      _buildMenuItem(context, 'Location'),
                      _buildMenuItem(context, 'My Route\'s'),
                      _buildMenuItem(context, 'My Rating\'s'),

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFF1C314A),

                        ),
                      ),

                      SizedBox(height: 10),

                      TextButton(
                        onPressed: () {},
                          child: Text(
                            'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                          ),
                        )
                    ],),
                ),
              )
        )
      ),
    );
  }
  Widget _buildMenuItem(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1C314A), // Gunakan warna yang konsisten
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}