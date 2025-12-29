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
  int following = 0;
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
        following = socials['following'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Failed load traveller profile: $e');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    // Label: Name
const Text(
  'Name',
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey,
  ),
),
const SizedBox(height: 4),

// Value: Username
Text(
  profile!.username,
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 12),

// Label: Rank
const Text(
  'Rank',
  style: TextStyle(
    fontSize: 13,
    color: Colors.grey,
  ),
),
const SizedBox(height: 4),

// Rank Value with icon
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
          (int.tryParse(profile!.rank.split(' ').last) ?? 1).toString(),
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



                   Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _buildStat('Followers', followers.toString()),
    _buildStat('Reviews', profile!.reviews.toString()),
    _buildStat('Routes', profile!.routes.toString()),
  ],
),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                       child: ElevatedButton(
  onPressed: _toggleFollow,
  style: ElevatedButton.styleFrom(
    backgroundColor: isFollowing ? Colors.grey : const Color.fromARGB(255, 15, 57, 92),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
),

                        ),
                        const SizedBox(width: 12),
                        Expanded(
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // ⬅️ di SINI gantinya
      ),
    ),
    child: const Text(
      'Report',
      style: TextStyle(color: Colors.white),
    ),
  ),
),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ...profile!.plans.map((plan) {
                final base64Str = plan['banner'] ?? '';
                Uint8List? planImg;
                if (base64Str.isNotEmpty) {
                  try {
                    planImg = base64Decode(base64Str);
                  } catch (_) {}
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: planImg != null
                        ? DecorationImage(
                            image: MemoryImage(planImg),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: planImg == null ? Colors.grey[300] : null,
                  ),
                  height: 140,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Text(plan['title'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                );
              }).toList(),
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
