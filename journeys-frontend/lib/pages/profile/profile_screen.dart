import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'presentation/edit_profile_screen.dart';
import 'presentation/my_route_screen.dart';
import 'presentation/my_rating_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe9ebee),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Profile'),
        titleTextStyle: const TextStyle(
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFF1C314A),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Name',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF1C314A),
                          ),
                      ),
                      const Text(
                        'ELALALANG',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C314A),
                          ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Rank\'s',
                        textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF1C314A),
                          ),
                      ),
                      
                      const SizedBox(height: 5),

                      // --- BAGIAN ICON BADGE ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Icon Lencana Solid Polos (Cupertino)
                              const Icon(
                                CupertinoIcons.shield_fill, 
                                color: Color(0xFF1C314A),
                                size: 32,
                              ),
                              // Angka Level
                              const Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10), 
                          const Text(
                            'Adventurer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C314A),
                            ),
                          ),
                        ],
                      ),
                      // -------------------------

                      const SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:90.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: const Color(0xFF1C314A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                          ),
                          child: const Text(
                            'Edit Profile',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildMenuItem(context, 'Languages'),
                      _buildMenuItem(context, 'Location'),
                      _buildMenuItem(context, 'My Route\'s', onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyRouteOwned()),
                        );
                      }),
                      _buildMenuItem(context, 'My Rating\'s', onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyRatingOwned()),
                        );
                      }),

                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(
                          color: Color(0xFF1C314A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {},
                          child: const Text(
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

  Widget _buildMenuItem(BuildContext context, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1C314A),
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}