import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/models/profile_model.dart';
import 'package:journeys/models/user_model.dart';
import 'package:journeys/services/api_service.dart';
import 'presentation/edit_profile_screen.dart';
import 'presentation/my_route_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  ProfileModel? _profile;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getUserMe(),
      ]);

      setState(() {
        _profile = results[0] as ProfileModel;
        _user = results[1] as UserModel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: $e')),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: $e')),
        );
      }
    }
  }

  // --- FUNGSI UNTUK MEMUNCULKAN POP UP ---
  void _showLevelPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar tinggi bisa disesuaikan
      backgroundColor: Colors.transparent, // Transparan agar sudut rounded terlihat
      builder: (context) => const LevelProgressBottomSheet(),
    );
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null || _user == null
              ? const Center(child: Text('Failed to load profile data.'))
              : SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 16.0),
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
                              Container(
                                width: 120.0,
                                height: 120.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C314A),
                                  shape: BoxShape.circle,
                                  image: _profile!.photo != null
                                      ? DecorationImage(
                                          image: MemoryImage(
                                              base64Decode(_profile!.photo!)),
                                          fit: BoxFit.scaleDown,
                                        )
                                      : null,
                                ),
                                child: _profile!.photo == null
                                    ? const Icon(Icons.person,
                                        size: 60, color: Colors.white)
                                    : null,
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
                              Text(
                                _user!.username.isNotEmpty
                                    ? _user!.username[0].toUpperCase() +
                                        _user!.username.substring(1)
                                    : _user!.username,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
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

                              // --- BAGIAN ICON BADGE (TRIGGER POPUP 1) ---
                              // Dibungkus GestureDetector agar bisa diklik
                              GestureDetector(
                                onTap: () => _showLevelPopup(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.shield_fill,
                                          color: Color(0xFF1C314A),
                                          size: 32,
                                        ),
                                        Text(
                                          _profile!.rank
                                              .split(' ')
                                              .last
                                              .replaceAll('lvl', ''),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _profile!.rank.split(' ').first,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1C314A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // -------------------------

                              const SizedBox(height: 40),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 90.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfileScreen()),
                                    );
                                    if (result == true) {
                                      setState(() => _isLoading = true);
                                      await _fetchData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    backgroundColor: const Color(0xFF1C314A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0),
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

                              _buildMenuItem(context,
                                  'Languages: ${_profile!.languages ?? ''}'),
                              _buildMenuItem(context,
                                  'Location: ${_profile!.location ?? ''}'),
                              _buildMenuItem(context, 'My Route\'s',
                                  onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyRouteOwned()),
                                );
                              }),
                              
                              // --- MY RATING'S (TRIGGER POPUP 2) ---
                              _buildMenuItem(context, 'My Rating\'s',
                                  onTap: () {
                                // Memanggil popup alih-alih pindah halaman
                                _showLevelPopup(context);
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
                                onPressed: _handleLogout,
                                child: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title,
      {VoidCallback? onTap}) {
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

// =========================================================
// WIDGET POP UP BARU (INTEGRASI UI DARI GAMBAR)
// =========================================================

class LevelProgressBottomSheet extends StatelessWidget {
  const LevelProgressBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Tinggi 85% layar
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // --- Handle Bar ---
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // --- CONTENT SCROLLABLE ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER: Badge & XP ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Besar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.shield_fill, // Menggunakan Shield Fill sesuai preferensi user
                            size: 80,
                            color: Color(0xFF1C314A),
                          ),
                          Text(
                            "1",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Roboto', 
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Info XP & Progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Scoe", 
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C314A),
                              ),
                            ),
                            const Text(
                              "XP 60",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Basic Planner",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C314A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Progress Bar Custom
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: 0.6, // 60% Progress
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1C314A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You need 40 more XP to up your Badge's!",
                    style: TextStyle(color: Color(0xFF1C314A), fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION: Your Review ---
                  const Text(
                    "Your Review",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C314A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Card Your Review
                  _buildReviewCard(
                    title: "The Getaway",
                    desc: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...",
                    location: "Bedugul - Gianyar",
                    stars: 5,
                    isDeletable: true,
                  ),
                  // Card Duplicate (Efek tumpuk)
                  Transform.translate(
                    offset: const Offset(0, -10), 
                    child: Opacity(
                      opacity: 0.5,
                      child: _buildReviewCard(
                        title: "The Getaway",
                        desc: "My own schedule trip to get to somewhere full with",
                        location: "",
                        stars: 0,
                        isDeletable: false,
                        mini: true,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // --- SECTION: Those Who Review You ---
                  const Text(
                    "Those Who Review You",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C314A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildReviewerCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER POPUP ---
  
  Widget _buildReviewCard({
    required String title,
    required String desc,
    required String location,
    required int stars,
    required bool isDeletable,
    bool mini = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[300], 
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1C314A),
                  ),
                ),
                if (!mini) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  if (location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 10, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          location,
                          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: index < stars ? Colors.amber : Colors.grey[300],
                      );
                    }),
                  ),
                ]
              ],
            ),
          ),
          // Delete Icon
          if (isDeletable)
            const Icon(Icons.delete_outline, size: 20, color: Color(0xFF1C314A)),
        ],
      ),
    );
  }

  Widget _buildReviewerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Avatar & Profile Info
          Column(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey, 
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 8),
              const Text(
                "Jackson",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1C314A),
                ),
              ),
              const Text(
                "Traveller",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C314A),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 24,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C314A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text(
                    "Follow",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          // Right Column: Review & Stars
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (index) => const Icon(Icons.star_rounded, size: 18, color: Colors.amber)),
                    ),
                    const Icon(Icons.delete, size: 18, color: Color(0xFF1C314A)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "The Scenery is cute, the place is comfy, the people are very friendly, i came here with my family, and we feel very nice being here",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1C314A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}