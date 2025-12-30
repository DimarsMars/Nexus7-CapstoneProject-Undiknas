import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journeys/services/api_service.dart';
import '../../../models/traveller_recomen_model.dart';
import '../../../models/most_active_traveller_model.dart';

class TravellerScreen extends StatefulWidget {
  const TravellerScreen({super.key});

  @override
  State<TravellerScreen> createState() => _TravellerScreenState();
}

class _TravellerScreenState extends State<TravellerScreen> {
  // ⬅️ WAJIB: pakai userId
  final Map<int, bool> _followedTravellers = {};

  List<TravellerRecommendationModel> youMayLike = [];
  List<MostActiveTravellerModel> mostActiveTravellers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final result = await ApiService().getCategoryTravellers();
      final mostActiveResult = await ApiService().getMostActiveTravellers();

      // ambil status follow dari backend
      for (var t in result) {
        final status = await ApiService().isFollowing(t.user.userId);
        _followedTravellers[t.user.userId] = status;
      }

      for (var t in mostActiveResult) {
        final status = await ApiService().isFollowing(t.userId);
        _followedTravellers[t.userId] = status;
      }

      setState(() {
        youMayLike = result;
        mostActiveTravellers = mostActiveResult;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  // ⬅️ LOGIKA FOLLOW / UNFOLLOW ASLI
  Future<void> _toggleFollow(int userId) async {
    final isFollowed = _followedTravellers[userId] ?? false;

    try {
      if (isFollowed) {
        await ApiService().unfollowUser(userId);
      } else {
        await ApiService().followUser(userId);
      }

      setState(() {
        _followedTravellers[userId] = !isFollowed;
      });
    } catch (e) {
      debugPrint('Follow error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEE),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find traveller...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'You may like (category)',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B263B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // YOU MAY LIKE
                    SizedBox(
                      height: 260,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: youMayLike.length,
                              itemBuilder: (context, index) {
                                final traveller = youMayLike[index].user;
                                return _buildTravellerCard(
                                  userId: traveller.userId,
                                  name: traveller.username,
                                  title: traveller.role,
                                  photoBase64: traveller.photoBase64,
                                  isFollowed: _followedTravellers[traveller.userId] ?? false,
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'Most Active Traveller',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B263B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // MOST ACTIVE
                    SizedBox(
                      height: 260,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: mostActiveTravellers.length,
                              itemBuilder: (context, index) {
                                final traveller = mostActiveTravellers[index];
                                return _buildTravellerCard(
                                  userId: traveller.userId,
                                  name: traveller.username,
                                  title: traveller.role,
                                  photoBase64: traveller.photoBase64,
                                  isFollowed: _followedTravellers[traveller.userId] ?? false,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _buildTravellerCard({
    required int userId,
    required String name,
    required String title,
    required String photoBase64,
    required bool isFollowed,
  }) {
    Widget imageWidget;
    try {
      imageWidget = photoBase64.isNotEmpty
          ? Image.memory(base64Decode(photoBase64.split(',').last), fit: BoxFit.cover)
          : Image.asset('assets/icons/profile.jpg', fit: BoxFit.cover);
    } catch (_) {
      imageWidget = Image.asset('assets/icons/profile.jpg', fit: BoxFit.cover);
    }

    return GestureDetector(
     onTap: () async {
  await context.push('/traveller-detail', extra: {'userId': userId});
  _loadRecommendations(); // refresh data setelah kembali
},

      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 16, bottom: 20, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
  radius: 42,
  backgroundImage: photoBase64.isNotEmpty
      ? MemoryImage(base64Decode(photoBase64.split(',').last))
      : const AssetImage('assets/icons/profile.jpg') as ImageProvider,
),
            const SizedBox(height: 12),
            Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 14),
            SizedBox(
              height: 32,
              width: 100,
              child: ElevatedButton(
                onPressed: () => _toggleFollow(userId),
              style: ElevatedButton.styleFrom(
  backgroundColor: isFollowed ? Colors.grey[300] : const Color(0xFF1B263B),
  foregroundColor: isFollowed ? Colors.black : Colors.white,
  elevation: 0,
  padding: EdgeInsets.zero,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
),

                child: Text(
                  isFollowed ? 'unfollow' : 'Follow',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
