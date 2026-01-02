import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:journeys/pages/route_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, String>> savedPlaces = [
    {
      'id': '15', // 🔥 ID PLACE (contoh)
      'name': 'Serenity Oasis',
      'category': 'Restaurant',
      'location': 'Bedugul - Gianyar.',
      'image': 'https://picsum.photos/150/90'
    },
    {
      'id': '16',
      'name': 'Dirty Diana',
      'category': 'Restaurant',
      'location': 'Bedugul - Gianyar.',
      'image': 'https://picsum.photos/150/91'
    },
  ];

  TextEditingController searchController = TextEditingController();

  // =================================================
  // FIREBASE TOKEN
  // =================================================
  Future<String?> getFirebaseToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  // =================================================
  // POST BOOKMARK API
  // =================================================
  Future<void> addBookmark(String placeId) async {
    final token = await getFirebaseToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("http://192.168.1.8:8080/bookmarks/$placeId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil ditambahkan ke bookmark")),
      );
    } else {
      debugPrint("Bookmark ERROR ${response.statusCode}");
      debugPrint(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan bookmark")),
      );
    }
  }

  // =================================================
  // UI
  // =================================================
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

  // =================================================
  // SEARCH BOX
  // =================================================
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh),
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

  // =================================================
  // SAVED HEADER
  // =================================================
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

  // =================================================
  // CARD ITEM
  // =================================================
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place['name']!,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(place['category']!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(place['location']!,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                )
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.black87),
                onPressed: () {
                  addBookmark(place['id']!); // 🔥 POST KE BACKEND
                },
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
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

  // =================================================
  // ADD TO ROUTE
  // =================================================
  Widget _buildAddToRouteButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF274664),
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
