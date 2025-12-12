import 'package:flutter/material.dart';
import 'package:journeys/pages/route_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, String>> savedPlaces = [
    {
      'name': 'Serenity Oasis',
      'category': 'Restaurant',
      'location': 'Bedugul - Gianyar.',
      'image': 'https://picsum.photos/150/90'
    },
    {
      'name': 'Dirty Diana',
      'category': 'Restaurant',
      'location': 'Bedugul - Gianyar.',
      'image': 'https://picsum.photos/150/91'
    },
  ];

  TextEditingController searchController = TextEditingController();

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
              child: ListView(
                children: [
                  ...savedPlaces.map((item) => _buildCard(item)),
                  const SizedBox(height: 20),
                  _buildAddToRouteButton(),
                  const SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // SEARCH BOX (Sesuai desain)
  // -------------------------------------------------

  Widget _buildSearchBox() {
    return Column(
      children: [
        const Text(
          "Search",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Restaurant...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // SAVED HEADER
  // -------------------------------------------------

  Widget _buildSavedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Saved",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() => savedPlaces.clear());
          },
          child: const Text(
            "Remove all",
            style: TextStyle(color: Color(0xFF274664)),
          ),
        )
      ],
    );
  }

  // -------------------------------------------------
  // CARD ITEM (Disesuaikan dengan gambar)
  // -------------------------------------------------

  Widget _buildCard(Map<String, String> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place['image']!,
              width: 75,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['name']!,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  place['category']!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      place['location']!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Bookmark & Icon Box
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.black87),
                onPressed: () {},
              ),

              // Kotak kecil (seperti gambar)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.crop_square, size: 16),
              )
            ],
          )
        ],
      ),
    );
  }

  // -------------------------------------------------
  // ADD TO ROUTE BUTTON (Sesuaikan gambar)
  // -------------------------------------------------

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
          MaterialPageRoute(builder: (context) => const RouteScreen()),
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
