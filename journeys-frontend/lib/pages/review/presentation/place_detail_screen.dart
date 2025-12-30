import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  int? _bookmarkId;

  PlaceDetail? _place;
  List<PlaceReview> _reviews = [];
  bool _isLoading = true;
  bool _isBookmarked = false;
List<Uint8List> _selectedImages = [];

  // DATA DUMMY UNTUK MORE PICTURES
  final List<String> _dummyMorePictures = [
    'assets/icons/review.jpg',
    'assets/icons/review.jpg',
    'assets/icons/review.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final place = await ApiService().getPlaceDetail(widget.routeId);
      final reviews = await ApiService().getPlaceReviews(widget.routeId);
      final bookmarkId = await ApiService().getBookmarkIdForRoute(widget.routeId);

      setState(() {
        _place = place;
        _reviews = reviews;
        _bookmarkId = bookmarkId;
        _isBookmarked = bookmarkId != null;
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
                        const Text('Add Review',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _reviewController.clear();
                            setModalState(() {
                              _rating = 0;
                              _selectedImages.clear(); // ✅ benar

                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                     final pickedFiles = await picker.pickMultiImage(imageQuality: 70);
if (pickedFiles != null) {
  final bytesList = await Future.wait(pickedFiles.map((f) => f.readAsBytes()));
  setModalState(() {
    _selectedImages.addAll(bytesList); // ✅ append, bukan replace
  });
}


                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _selectedImages.isNotEmpty
    ? ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _selectedImages[index],
                width: 120,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      )
    : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Add Images',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      )

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
                              onTap: () =>
                                  setModalState(() => _rating = index + 1),
                              child: Icon(
                                Icons.star,
                                size: 32,
                                color: index < _rating
                                    ? Colors.amber
                                    : Colors.grey[300],
                              ),
                            );
                          }),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                              if (_reviewController.text.isNotEmpty && _rating > 0) {
                                final currentContext = context; // ✅ simpan context sebelum pop
                                Navigator.of(currentContext).pop(); // ✅ hindari gunakan context langsung setelah pop

                                final success = await ApiService().submitPlaceReview(
                                  routeId: widget.routeId,
                                  rating: _rating,
                                  comment: _reviewController.text,
                                  imageBytesList: _selectedImages,
                                );

                                _reviewController.clear();
                                _selectedImages.clear();

                                if (!mounted) return; // ✅ pastikan widget masih hidup

                                if (success) {
                                  ScaffoldMessenger.of(currentContext).showSnackBar(
                                    const SnackBar(content: Text('Review submitted successfully!')),
                                  );
                                  await _loadData(); // refresh review list
                                } else {
                                  ScaffoldMessenger.of(currentContext).showSnackBar(
                                    const SnackBar(content: Text('Failed to submit review')),
                                  );
                                }

                                setState(() => _rating = 0);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please add a review and rating')),
                                );
                              }
                            }
                              ,
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
    final List<String> image =
        _place != null && _place!.imageBase64.isNotEmpty
            ? [_place!.imageBase64]
            : ['assets/icons/serenity-oasis.jpg'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(Icons.star,
                                        size: 20,
                                        color: index < 4
                                            ? Colors.amber
                                            : Colors.grey[300]);
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 280,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: image.length,
                                      itemBuilder: (context, index) {
                                        final img = image[index];
                                        return img.startsWith('/') || img.length > 100
                                            ? Image.memory(base64Decode(img),
                                                fit: BoxFit.cover)
                                            : Image.asset(img,
                                                fit: BoxFit.cover);
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
                                      count: image.length,
                                      effect: ScrollingDotsEffect(
                                        activeDotColor: const Color(0xFF1E3A5F),
                                        dotColor: Colors.white.withOpacity(0.5),
                                        dotHeight: 8,
                                        dotWidth: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: _showAddReviewModal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 74, 91, 122),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Add review',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Review from the people's",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () async {
                                    if (_isBookmarked && _bookmarkId != null) {
                                      final success = await ApiService().removeBookmark(_bookmarkId!);
                                      if (success) {
                                        setState(() {
                                          _isBookmarked = false;
                                          _bookmarkId = null;
                                        });
                                      }
                                    } else {
                                      final success = await ApiService().addBookmark(widget.routeId);
                                      if (success) {
                                        final newId = await ApiService().getBookmarkIdForRoute(widget.routeId);
                                        setState(() {
                                          _isBookmarked = true;
                                          _bookmarkId = newId;
                                        });
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: _isBookmarked ? const Color.fromARGB(255, 74, 91, 122) : Colors.black,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_reviews.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: _reviews.map((review) {
                                  return Container(
                                    width: 320,
                                    margin: const EdgeInsets.only(right: 16, bottom: 8),
                                    padding: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8)
                                      ],
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                bottomRight: Radius.circular(16),
                                              ),
                                             child: review.imageBase64List.isNotEmpty
  ? Image.memory(
      base64Decode(review.imageBase64List[0]),
      width: 100,
      height: 120,
      fit: BoxFit.cover,
    )

    : Image.asset(
        'assets/icons/review.jpg',
        width: 100,
        height: 120,
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
                                                      children: List.generate(5, (starIndex) {
                                                        return Icon(
                                                          starIndex < review.rating
                                                              ? Icons.star
                                                              : Icons.star_border,
                                                          size: 18,
                                                          color: Colors.amber,
                                                        );
                                                      }),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    const Text('Review',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      height: 50,
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey[300]!),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: SingleChildScrollView(
                                                        child: Text(
                                                          review.comment,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey[600]),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('More picture from the reviews',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                 ...review.imageBase64List
    .skip(1) // ambil dari gambar ke-2
    .map((img) => Container(
          margin: const EdgeInsets.only(right: 8),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: MemoryImage(base64Decode(img)),
              fit: BoxFit.cover,
            ),
          ),
        ))
    .toList(),
                                                  const Spacer(),
                                                  TextButton(
                                                    onPressed: () {},
                                                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                                    child: const Text('See More Picture',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            decoration: TextDecoration.underline)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
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
