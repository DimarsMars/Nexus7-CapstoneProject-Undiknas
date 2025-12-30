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
  final Set<String> _followedTravellers = {};
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

      setState(() {
        youMayLike = result;
        mostActiveTravellers = mostActiveResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
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
              padding: const EdgeInsets.all(16.0),
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
                    hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
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
                    // Header You May Like - RATA TENGAH
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

                    // List You May Like
                    SizedBox(
                      height: 260, // Sedikit ditambah agar shadow tidak terpotong
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
                                  isFollowed: _followedTravellers.contains(traveller.username),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 32),

                    // Header Most Active - RATA TENGAH
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

                    // List Most Active
                    SizedBox(
                      height: 260, // Sedikit ditambah agar shadow tidak terpotong
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
                                  isFollowed: _followedTravellers.contains(traveller.username),
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

  // ===================== CARD RE-DESIGN DENGAN SHADOW TIMBUL =====================
  Widget _buildTravellerCard({
    required int userId,
    required String name,
    required String title,
    required String photoBase64,
    required bool isFollowed,
  }) {
    Widget imageWidget;
    if (photoBase64.isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(photoBase64.split(',').last);
        imageWidget = Image.memory(bytes, width: 85, height: 85, fit: BoxFit.cover);
      } catch (e) {
        imageWidget = Image.asset('assets/icons/profile.jpg', width: 85, height: 85, fit: BoxFit.cover);
      }
    } else {
      imageWidget = Image.asset('assets/icons/profile.jpg', width: 85, height: 85, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: () => context.push('/traveller-detail', extra: {'userId': userId, 'name': name}),
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 16, bottom: 20, top: 5), // Bottom margin ditambah untuk ruang shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12), // Lebih pekat sedikit
              blurRadius: 15, // Efek sebaran bayangan lebih luas
              spreadRadius: 1, // Bayangan sedikit melebar
              offset: const Offset(0, 8), // Shadow jatuh ke bawah untuk efek timbul melayang
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[100]!, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1B263B)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 32,
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isFollowed) {
                      _followedTravellers.remove(name);
                    } else {
                      _followedTravellers.add(name);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B263B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isFollowed ? 'Followed' : 'Follow',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}