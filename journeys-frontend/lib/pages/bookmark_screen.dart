import 'package:flutter/material.dart';

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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black ),
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
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF274664),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Add to route",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...savedPlaces.map((item) => _buildCard(item)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --------------------------------------------
  // Search Box
  // --------------------------------------------

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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.autorenew),
              onPressed: () {},
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------
  // Saved Header
  // --------------------------------------------

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

  // --------------------------------------------
  // Card Item
  // --------------------------------------------

  Widget _buildCard(Map<String, String> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place['image']!,
              width: 80,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['name']!,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  place['category']!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      place['location']!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                )
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
              const Icon(Icons.crop_square, size: 26)
            ],
          )
        ],
      ),
    );
  }
}
