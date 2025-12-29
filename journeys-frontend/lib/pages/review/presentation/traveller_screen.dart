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
      final mostActiveResult =
          await ApiService().getMostActiveTravellers();

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
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Find traveller...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'You may like',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // YOU MAY LIKE
                    SizedBox(
                      height: 240,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: youMayLike.length,
                              itemBuilder: (context, index) {
                                final traveller = youMayLike[index].user;

                                dynamic imageData;
                                if (traveller.photoBase64.isNotEmpty) {
                                  imageData = base64Decode(
                                    traveller.photoBase64.split(',').last,
                                  );
                                } else {
                                  imageData = 'assets/icons/profile.jpg';
                                }

                                return _buildTravellerCard(
                                  userId: traveller.userId,
                                  name: traveller.username,
                                  title: traveller.role,
                                  imageUrl: imageData,
                                  isFollowed: _followedTravellers
                                      .contains(traveller.username),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 32),

                    // MOST ACTIVE
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Most Active Traveller',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 240,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: mostActiveTravellers.length,
                              itemBuilder: (context, index) {
                                final traveller =
                                    mostActiveTravellers[index];

                                dynamic imageData;
                                if (traveller.photoBase64.isNotEmpty) {
                                  imageData = base64Decode(
                                    traveller.photoBase64.split(',').last,
                                  );
                                } else {
                                  imageData = 'assets/icons/profile.jpg';
                                }

                                return _buildTravellerCard(
                                  userId: traveller.userId,
                                  name: traveller.username,
                                  title: traveller.role,
                                  imageUrl: imageData,
                                  isFollowed: _followedTravellers
                                      .contains(traveller.username),
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

  // ===================== CARD =====================
  Widget _buildTravellerCard({
    required int userId,
    required String name,
    required String title,
    required dynamic imageUrl,
    required bool isFollowed,
  }) {
    Image imageWidget;

    if (imageUrl is Uint8List) {
      imageWidget =
          Image.memory(imageUrl, width: 80, height: 80, fit: BoxFit.cover);
    } else {
      imageWidget =
          Image.asset(imageUrl, width: 80, height: 80, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: () => context.push(
        '/traveller-detail',
        extra: {
          'userId': userId,
          'name': name,
        },
      ),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: imageWidget,
            ),
            const SizedBox(height: 12),
            Text(name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title,
                style:
                    TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isFollowed) {
                    _followedTravellers.remove(name);
                  } else {
                    _followedTravellers.add(name);
                  }
                });
              },
              child: Text(isFollowed ? 'Followed' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
