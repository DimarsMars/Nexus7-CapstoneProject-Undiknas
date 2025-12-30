import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/services/api_service.dart';
import 'package:journeys/models/traveller_profile_model.dart';

class TravellerDetailScreen extends StatefulWidget {
  final int userId;

  const TravellerDetailScreen({super.key, required this.userId});

  @override
  State<TravellerDetailScreen> createState() => _TravellerDetailScreenState();
}

class _TravellerDetailScreenState extends State<TravellerDetailScreen> {
  TravellerProfileModel? profile;
  bool isFollowing = false;
  int followers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prof = await ApiService().getUserProfile(widget.userId);
      final followStatus = await ApiService().isFollowing(widget.userId);
      final socials = await ApiService().getSocialCounts(widget.userId);

      setState(() {
        profile = prof;
        isFollowing = followStatus;
        followers = socials['followers'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (isFollowing) {
      await ApiService().unfollowUser(widget.userId);
    } else {
      await ApiService().followUser(widget.userId);
    }
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    Uint8List? imageBytes;
    if (profile!.photoBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(profile!.photoBase64.split(',').last);
      } catch (_) {
        imageBytes = null;
      }
    }

return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120, // Menambah lebar agar teks "Back" muat
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.arrow_back, color: Colors.black),
              SizedBox(width: 4),
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ================= PROFILE CARD =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: imageBytes != null
                          ? MemoryImage(imageBytes)
                          : const AssetImage('assets/icons/default_avatar.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 16),

                    // Label Name
                    const Text(
                      'Name',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      profile!.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Label Rank
                    const Text(
                      'Rank',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),

                    // ✅ RANK DENGAN ICON (DIKEMBALIKAN)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.brightness_7,
                              size: 34,
                              color: Color(0xFF1E3A5F),
                            ),
                            Text(
                              (int.tryParse(
                                          profile!.rank.split(' ').last) ??
                                      1)
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile!.rank.split(' lvl').first,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Followers', followers.toString()),
                        _buildStat('Reviews', profile!.reviews.toString()),
                        _buildStat('Routes', profile!.routes.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.grey[300]
                                : const Color(0xFF1E3A5F),
                            foregroundColor: isFollowing
                                ? Colors.black
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isFollowing ? 'Unfollow' : 'Follow',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Report',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= PLANS LIST =================
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profile!.plans.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final plan = profile!.plans[index];
                  Uint8List? planImg;
                  if (plan['banner'] != null) {
                    try {
                      planImg =
                          base64Decode(plan['banner']!.split(',').last);
                    } catch (_) {
                      planImg = null;
                    }
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      image: planImg != null
                          ? DecorationImage(
                              image: MemoryImage(planImg),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.black.withOpacity(0.4),
  ),
  child: Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plan['title'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'By ${plan['author_name'] ?? 'Unknown'}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (i) {
            return Icon(
              Icons.star,
              size: 14,
              color: i < (plan['rating'] ?? 0)
                  ? Colors.amber
                  : Colors.grey[400],
            );
          }),
        ),
      ],
    ),
  ),
),

                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
