import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:journeys/models/my_trip_review_model.dart';
import 'package:journeys/models/review_on_my_plan_model.dart';
import 'package:journeys/models/profile_model.dart';
import 'package:journeys/models/user_xp_model.dart';
import 'package:journeys/services/api_service.dart';

class LevelProgressBottomSheet extends StatefulWidget {
  final List<ReviewOnMyPlanModel> reviewsOnMyPlans;

  const LevelProgressBottomSheet({
    super.key,
    required this.reviewsOnMyPlans,
  });

  @override
  State<LevelProgressBottomSheet> createState() => _LevelProgressBottomSheetState();
}


class _LevelProgressBottomSheetState extends State<LevelProgressBottomSheet> {
  // State for Reviews
  List<MyTripReviewModel> _myReviews = [];
  bool _isLoadingMyReviews = true;
  String? _errorMyReviews;

  // State for Profile & XP
  ProfileModel? _profile;
  UserXpModel? _userXP;
  bool _isLoadingProfile = true;
  String? _errorProfile;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoadingProfile = true;
      _errorProfile = null;
    });
    try {
      final profile = await _apiService.getProfile();
      final userXP = await _apiService.getUserXP();
      setState(() {
        _profile = profile;
        _userXP = userXP;
      });
    } catch (e) {
      setState(() {
        _errorProfile = 'Failed to load profile data: $e';
      });
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchMyReviews() async {
    setState(() {
      _isLoadingMyReviews = true;
      _errorMyReviews = null;
    });
    try {
      final reviews = await _apiService.getMyTripReviews();
      setState(() {
        _myReviews = reviews;
      });
    } catch (e) {
      setState(() {
        _errorMyReviews = 'Failed to load your reviews: $e';
      });
    } finally {
      setState(() {
        _isLoadingMyReviews = false;
      });
    }
  }

  Future<void> _onDeleteMyReview(int reviewId) async {
    final bool confirmDelete = await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        await _apiService.deleteReviewTrips(reviewId);
        _fetchMyReviews(); // Refresh the list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, 
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
                  _isLoadingProfile
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                      : _errorProfile != null
                          ? Center(child: Text(_errorProfile!))
                          : _profile == null || _userXP == null
                              ? const Center(child: Text('Profile data is not available.'))
                              : Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Badge Besar
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            const Icon(
                                              CupertinoIcons.shield_fill,
                                              size: 80,
                                              color: Color(0xFF1C314A),
                                            ),
                                            Text(
                                              _profile!.rank.split(' ').last,
                                              style: const TextStyle(
                                                fontSize: 30,
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
                                        // 1. HAPUS ConstrainedBox yang membatasi maxWidth: 50
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "My Score",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1C314A),
                                              ),
                                            ),
                                            Text(
                                              "XP ${_userXP!.xp}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _userXP!.rank,
                                              // maxLines: 1, // Opsional: biar teks rank tidak turun ke bawah
                                              // overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1C314A),
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // --- PERBAIKAN DI SINI ---
                                            // 2. Bungkus Stack (Progress Bar) dengan SizedBox yang punya width tertentu
                                            SizedBox(
                                              width: 140, // Atur panjang bar di sini (misal 140 atau 150 biar pas)
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                  FractionallySizedBox(
                                                    // Pastikan progressPercentage nilainya 0.0 sampai 1.0
                                                    widthFactor: _userXP!.progressPercentage.clamp(0.0, 1.0), 
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
                                            ),
                                            // -------------------------
                                          ],
                                        ),
                                      )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "You need ${_userXP!.nextLevelXp - _userXP!.xp} more XP to up your Badge's!",
                                      style: const TextStyle(color: Color(0xFF1C314A), fontSize: 14),
                                    ),
                                  ],
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
                  
                  // List Your Reviews
                  _isLoadingMyReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMyReviews != null
                          ? Center(child: Text(_errorMyReviews!))
                          : _myReviews.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text('You have not made any reviews yet.'),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _myReviews.length,
                                  itemBuilder: (context, index) {
                                    final review = _myReviews[index];
                                    return _buildReviewCard(
                                      reviewId: review.reviewId,
                                      image: review.plan.banner ?? "", // Handle null safety
                                      title: review.plan.title,
                                      desc: review.comment,
                                      location: review.plan.description ?? "", // Assuming plan description can be location
                                      stars: review.rating.toInt(),
                                      isDeletable: true,
                                      onDelete: _onDeleteMyReview,
                                    );
                                  },
                                ),
                  
                  const SizedBox(height: 24),

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
                  
                  // List Reviewers
                  widget.reviewsOnMyPlans.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('No one has reviewed your plans yet.'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.reviewsOnMyPlans.length,
                          itemBuilder: (context, index) {
                            final review = widget.reviewsOnMyPlans[index];
                            return _buildReviewerCard(review: review);
                          },
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Card "Your Review" ---
  Widget _buildReviewCard({
    required int reviewId,
    required String image,
    required String title,
    required String desc,
    required String location,
    required int stars,
    required bool isDeletable,
    Function(int)? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              child: image.isNotEmpty
                  ? Image.memory(
                      base64Decode(image.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
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
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                        ),
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
              ],
            ),
          ),
          // Delete Icon
          if (isDeletable && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF1C314A)),
              onPressed: () => onDelete(reviewId),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Card "Those Who Review You" ---
  Widget _buildReviewerCard({required ReviewOnMyPlanModel review}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey,
                backgroundImage: (review.user?.photo != null && review.user!.photo.isNotEmpty)
                    ? MemoryImage(base64Decode(review.user!.photo.split(',').last))
                    : null,
                child: (review.user.photo == null || review.user!.photo.isEmpty)
                    ? const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                review.user.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1C314A),
                ),
              ),
              Text(
                review.user.rank,
                style: const TextStyle(
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
                      children: List.generate(5, (index) => Icon(Icons.star_rounded, size: 18, color: index < (review.rating ?? 0) ? Colors.amber : Colors.grey[300])),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: const TextStyle(
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