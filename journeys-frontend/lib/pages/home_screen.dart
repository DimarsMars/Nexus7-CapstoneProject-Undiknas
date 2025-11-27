import 'package:flutter/material.dart';
import 'package:journeys/pages/category.dart';
import 'package:journeys/pages/travellers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Culture';

  // gambar untuk Plan's Category
  static const Map<String, String> planCategoryImages = {
    "Temple":
        "https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=500&q=80",
    "Beach":
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500&q=80",
    "Mini Resto":
        "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=500&q=80",
    "Store's":
        "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=500&q=80",
  };

  final List<String> categories = [
    'Culture',
    'Eatery',
    'Health',
    "Craft's",
  ];

  // data dummy trips per category
  final Map<String, List<Map<String, String>>> tripsByCategory = {
    'Culture': [
      {'title': 'Culture Trip', 'author': 'Horas B.'},
      {'title': 'Ancient Temples', 'author': 'Sinta C.'},
    ],
    'Eatery': [
      {'title': 'Food Exploration', 'author': 'Deni S.'},
      {'title': 'Mini Resto Tour', 'author': 'Aulia F.'},
    ],
    'Health': [
      {'title': 'Trip of Health', 'author': 'Thomas A.'},
      {'title': 'Yoga Retreat', 'author': 'Lina P.'},
    ],
    "Craft's": [
      {'title': 'Craft Workshop', 'author': 'Maya L.'},
      {'title': 'Art & Craft', 'author': 'Riko H.'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentTrips = tripsByCategory[selectedCategory]!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),

      // ========== NAVBAR SUDAH DIHAPUS ==========

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 🔍 SEARCH BAR
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Find a place...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔹 CATEGORY TABS
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((cat) {
                    final isActive = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // 🗺 TRIP CARDS
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentTrips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    final trip = currentTrips[index];
                    return _tripCard(trip['title']!, trip['author']!);
                  },
                ),
              ),

              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Explore More",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

              const SizedBox(height: 24),

              // 🧭 FORGE YOUR ROUTE
              const Text(
                "Forge Your Route",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // ⭐ BANNER WITH IMAGE
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Create your own plan",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 📍 PLAN'S CATEGORY
              const Text(
                "Plan's Category",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryCardWithImage(
                        "Temple", planCategoryImages["Temple"]!),
                    _categoryCardWithImage(
                        "Beach", planCategoryImages["Beach"]!),
                    _categoryCardWithImage(
                        "Mini Resto", planCategoryImages["Mini Resto"]!),
                    _categoryCardWithImage(
                        "Store's", planCategoryImages["Store's"]!),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "See More",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 👥 FOLLOW TRAVELLERS
              const Text(
                "Follow These Travellers",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _TravellerCardHome(
                      name: "Jackson",
                      role: "Traveller",
                      imageUrl:
                          "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=500&q=80",
                    ),
                    _TravellerCardHome(
                      name: "Bob",
                      role: "Map Maker",
                      imageUrl:
                          "https://images.unsplash.com/photo-1552058544-f2b08422138a?auto=format&fit=crop&w=500&q=80",
                    ),
                    _TravellerCardHome(
                      name: "Alice",
                      role: "Explorer",
                      imageUrl:
                          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=500&q=80",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravellersPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "See More",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGETS =================
  static Widget _tripCard(String title, String author) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(author, style: const TextStyle(fontSize: 12)),
          const Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber),
              Icon(Icons.star, size: 14, color: Colors.amber),
              Icon(Icons.star, size: 14, color: Colors.amber),
              Icon(Icons.star, size: 14, color: Colors.amber),
              Icon(Icons.star, size: 14, color: Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _categoryCardWithImage(String name, String imageUrl) {
    return Container(
      width: 86,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _TravellerCardHome extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;

  const _TravellerCardHome({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 35, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(height: 8),
          Text(name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(role, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(80, 28),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Follow",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
