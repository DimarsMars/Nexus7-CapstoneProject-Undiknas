import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/models/profile_model.dart';
import 'package:journeys/models/user_model.dart';
import 'package:journeys/services/api_service.dart';
import 'presentation/edit_profile_screen.dart';
import 'presentation/my_route_screen.dart';
import 'package:journeys/models/review_on_my_plan_model.dart';
import 'presentation/level_popup.dart'; 

// Widget utama untuk layar profil menggunakan StatefulWidget untuk menangani perubahan data
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _MyProfileScreen();
}

// State class yang mengelola logika, pengambilan data, dan tampilan layar profil
class _MyProfileScreen extends State<ProfileScreen> {
  // Inisialisasi layanan API dan variabel penyimpanan data profil/user
  final ApiService _apiService = ApiService();
  ProfileModel? _profile;
  UserModel? _user;
  List<ReviewOnMyPlanModel> _reviewsOnMyPlans = [];
  bool _isLoading = true; // State untuk mengontrol tampilan loading

  // Lifecycle initState: dipanggil pertama kali saat layar dibuat untuk memicu pengambilan data
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi asinkron untuk mengambil data profil, user, dan ulasan secara paralel menggunakan Future.wait
  Future<void> _fetchData() async {
    try {
      if (!mounted) return;

      // Mengambil data dari tiga endpoint API sekaligus untuk efisiensi
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getUserMe(),
        _apiService.getReviewsOnMyPlans(),
      ]);

      if (mounted) {
        setState(() {
          // Memasukkan hasil response API ke dalam variabel state
          _profile = results[0] as ProfileModel;
          _user = results[1] as UserModel;
          _reviewsOnMyPlans = results[2] as List<ReviewOnMyPlanModel>;
          _isLoading = false; // Mematikan status loading setelah data didapat
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Menampilkan pesan error jika proses pengambilan data gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data: $e')),
        );
      }
    }
  }

  // Fungsi untuk menangani proses logout dari Firebase dan navigasi kembali ke halaman login
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

  // Fungsi untuk memunculkan Bottom Sheet yang menampilkan progres level pengguna
  void _showLevelPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => LevelProgressBottomSheet(
        reviewsOnMyPlans: _reviewsOnMyPlans,
      ),
    );
  }

  // Metode build untuk merender seluruh antarmuka pengguna layar profil
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
      // Logika percabangan: Tampilkan loading, pesan error, atau konten utama
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
                              // Widget untuk menampilkan Foto Profil (Base64 atau Default Icon)
                              Container(
                                width: 120.0,
                                height: 230.0,
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
                              // Label dan Tampilan Nama Pengguna (Kapitalisasi huruf pertama)
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

                              // Tombol interaktif untuk menampilkan detail Level/Rank dalam bentuk Badge
                              GestureDetector(
                                onTap: _showLevelPopup,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const Icon(
                                          Icons.brightness_7,
                                          color: Color(0xFF1C314A),
                                          size: 34,
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

                              const SizedBox(height: 40),

                              // Tombol Edit Profil untuk menavigasi ke EditProfileScreen
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
                                    // Refresh data jika user baru saja melakukan update profil
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

                              _buildMenuItem(context, 'My Route\'s',
                                  onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyRouteOwned()),
                                );
                              }),
                              _buildMenuItem(context, 'My Rating\'s',
                                  onTap: () {
                                _showLevelPopup();
                              }),

                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Divider(
                                  color: Color(0xFF1C314A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Tombol Logout untuk keluar dari aplikasi
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

  // Widget Helper untuk membangun item menu daftar agar tampilan kode lebih bersih dan modular
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