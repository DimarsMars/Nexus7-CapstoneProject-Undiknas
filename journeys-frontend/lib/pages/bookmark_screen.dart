import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:journeys/pages/route_screen.dart';
import 'package:journeys/services/api_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _bookmarks;
  final TextEditingController searchController = TextEditingController();

List<Map<String, dynamic>> savedPlaces = [];

  @override
  void initState() {
    super.initState();
    _bookmarks = apiService.getAllBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F4),
      appBar: AppBar(
        title: const Text(
          "Bookmarked",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0.3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBox(),
            const SizedBox(height: 16),
            _buildSavedHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _bookmarks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No bookmarks found."));
                  }

                  final savedPlaces = snapshot.data!;
                  return ListView(
                    children: [
                      ...savedPlaces.map((item) => _buildCard(item)),
                      const SizedBox(height: 20),
                      _buildAddToRouteButton(),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Column(
      children: [
        const Text(
          "Search",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Restaurant...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Saved",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _bookmarks = Future.value([]);
            });
          },
          child: const Text(
            "Remove all",
            style: TextStyle(color: Color(0xFF274664)),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> place) {
  final base64Image = place['image'] ?? '';
  final imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 52,
                  height: 52,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                place['description'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.place, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      place['address'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
       Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(
        Icons.bookmark,
        color: Colors.black87, // Bookmark aktif
        size: 20,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bookmark aktif")),
        );
      },
    ),
    GestureDetector(
      onTap: () async {
        await apiService.removeBookmark(place['bookmark_id']);
        setState(() {
          _bookmarks = apiService.getAllBookmarks();
        });
      },
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.delete, size: 16),
      ),
    ),
  ],
)

      ],
    ),
  );
}


  Widget _buildAddToRouteButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF274664),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RouteScreen()),
          );
        },
        child: const Text(
          "Add to route",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
