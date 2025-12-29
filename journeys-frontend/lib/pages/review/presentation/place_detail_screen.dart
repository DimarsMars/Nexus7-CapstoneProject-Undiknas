// TOP: Tetap sama (tidak berubah)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:journeys/services/api_service.dart';
import '../../../models/place_detail.dart';
import '../../../models/place_review.dart';
import 'package:go_router/go_router.dart';

class PlaceDetailScreen extends StatefulWidget {
  final int routeId;

  const PlaceDetailScreen({super.key, required this.routeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  PlaceDetail? _place;
  List<PlaceReview> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final place = await ApiService().getPlaceDetail(widget.routeId);
      final reviews = await ApiService().getPlaceReviews(widget.routeId);

      setState(() {
        _place = place;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading place detail: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _showAddReviewModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _reviewController.clear();
                            setModalState(() => _rating = 0);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image picker will be implemented')),
                        );
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text('Add Image', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _reviewController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write a Review...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setModalState(() => _rating = index + 1),
                              child: Icon(
                                Icons.star,
                                size: 32,
                                color: index < _rating ? Colors.amber : Colors.grey[300],
                              ),
                            );
                          }),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_reviewController.text.isNotEmpty && _rating > 0) {
                              Navigator.of(context).pop();
                              _reviewController.clear();
                              setState(() => _rating = 0);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Review submitted successfully!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please add a review and rating')),
                              );
                            }
                          },
                          child: const Text('Add review'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = _place != null && _place!.imageBase64.isNotEmpty
        ? [_place!.imageBase64]
        : ['assets/icons/serenity-oasis.jpg'];

    final List<String> reviewImages = _reviews
        .where((r) => r.imageBase64.isNotEmpty)
        .map((r) => r.imageBase64)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Find a place...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with back and title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Icon(Icons.chevron_left, size: 32),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _place?.title ?? 'Place Name',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(Icons.star, size: 20, color: index < 4 ? Colors.amber : Colors.grey[300]);
                                  }),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Image carousel
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 280,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: images.length,
                                      itemBuilder: (context, index) {
                                        final img = images[index];
                                        return img.startsWith('/')
                                            ? Image.memory(base64Decode(img), fit: BoxFit.cover)
                                            : Image.asset(img, fit: BoxFit.cover);
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: SmoothPageIndicator(
                                      controller: _pageController,
                                      count: images.length,
                                      effect: ScrollingDotsEffect(
                                        activeDotColor: const Color(0xFF1E3A5F),
                                        dotColor: Colors.white.withOpacity(0.5),
                                        dotHeight: 8,
                                        dotWidth: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: ElevatedButton(
                                    onPressed: _showAddReviewModal,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A5B7A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Add review', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Review section header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Review from the people's", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Icon(Icons.bookmark_border, size: 24),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Review card
                          if (_reviews.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: _reviews[0].imageBase64.isNotEmpty
                                          ? Image.memory(
                                              base64Decode(_reviews[0].imageBase64),
                                              width: 120,
                                              height: 160,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/icons/review.jpg',
                                              width: 120,
                                              height: 160,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: List.generate(5, (index) {
                                                return Icon(
                                                  index < _reviews[0].rating ? Icons.star : Icons.star_border,
                                                  size: 20,
                                                  color: Colors.amber,
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text('Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Text(
                                              _reviews[0].comment,
                                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // More pictures section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('More picture from the reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('See More Picture', style: TextStyle(decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: reviewImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      base64Decode(reviewImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
