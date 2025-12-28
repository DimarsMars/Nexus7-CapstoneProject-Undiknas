import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final mostActiveResult = await ApiService().getMostActiveTravellers(); // <- tambah ini
    setState(() {
      youMayLike = result;
      mostActiveTravellers = mostActiveResult; // <- dan ini
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mostActive = [
      {'name': 'Jackson', 'title': 'Traveller', 'image': 'assets/icons/jackson.jpg'},
      {'name': 'Bob', 'title': 'Map Maker', 'image': 'assets/icons/bob.jpg'},
      {'name': 'Maria', 'title': 'Blogger', 'image': 'assets/icons/maria_alice.jpg'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find traveller...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Back Button and Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 28,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'You may like (Categories #)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // You may like section
                    SizedBox(
                      height: 240,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: youMayLike.length,
                              itemBuilder: (context, index) {
                                final traveller = youMayLike[index].user;
                                final name = traveller.username;
                                final title = traveller.role;

                               dynamic imageData;
                                if (traveller.photoBase64.isNotEmpty) {
                                  final clean = traveller.photoBase64.split(',').last;
                                  imageData = base64Decode(clean);
                                } else {
                                  imageData = 'assets/icons/profile.jpg'; // Gambar dummy kamu
                                }


                                return _buildTravellerCard(
                                  name: name,
                                  title: title,
                                  imageUrl: imageData,
                                  isFollowed: _followedTravellers.contains(name),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 32),

                    // Most Active Traveller Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Most Active Traveller',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Most Active section
                   SizedBox(
  height: 240,
  child: isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: mostActiveTravellers.length,
          itemBuilder: (context, index) {
            final traveller = mostActiveTravellers[index];
            final name = traveller.username;
            final title = traveller.role;

            dynamic imageData;
            if (traveller.photoBase64.isNotEmpty) {
              final clean = traveller.photoBase64.split(',').last;
              imageData = base64Decode(clean);
            } else {
              imageData = 'assets/icons/profile.jpg';
            }

            return _buildTravellerCard(
              name: name,
              title: title,
              imageUrl: imageData,
              isFollowed: _followedTravellers.contains(name),
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

  Widget _buildTravellerCard({
    required String name,
    required String title,
    required dynamic imageUrl,
    required bool isFollowed,
  }) {
    Image imageWidget;

    if (imageUrl is Uint8List) {
      imageWidget = Image.memory(imageUrl, width: 80, height: 80, fit: BoxFit.cover);
    } else if (imageUrl is String) {
      imageWidget = Image.asset(imageUrl, width: 80, height: 80, fit: BoxFit.cover);
    } else {
      imageWidget = Image.asset('assets/icons/default_avatar.png', width: 80, height: 80);
    }

    return GestureDetector(
      onTap: () => context.push('/traveller-detail', extra: name),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_followedTravellers.contains(name)) {
                    _followedTravellers.remove(name);
                  } else {
                    _followedTravellers.add(name);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowed ? Colors.grey[400] : const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isFollowed ? 'Followed' : 'Follow',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
