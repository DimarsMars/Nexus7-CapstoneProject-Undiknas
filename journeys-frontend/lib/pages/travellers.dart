import 'package:flutter/material.dart';

class TravellersPage extends StatefulWidget {
  const TravellersPage({super.key});

  @override
  State<TravellersPage> createState() => _TravellersPageState();
}

class _TravellersPageState extends State<TravellersPage> {
  final List<Map<String, String>> travellers = [
    {
      'name': 'Jackson',
      'role': 'Traveller',
      'image': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
    },
    {
      'name': 'Bob',
      'role': 'Map Maker',
      'image': 'https://images.unsplash.com/photo-1552058544-f2b08422138a?auto=format&fit=crop&w=500&q=80',
    },
    {
      'name': 'Alice',
      'role': 'Explorer',
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    },
  ];

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filtered = travellers
        .where((t) =>
            t['name']!.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Travellers",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔍 Search bar
          Container(
            margin: const EdgeInsets.only(bottom: 20),
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
            child: TextField(
              onChanged: (val) => setState(() => searchText = val),
              decoration: const InputDecoration(
                hintText: 'Find traveller...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              ),
            ),
          ),

          // 👥 Traveller list
          GridView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final traveller = filtered[index];
              return _TravellerCard(
                imageUrl: traveller['image']!,
                name: traveller['name']!,
                role: traveller['role']!,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TravellerCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String role;

  const _TravellerCard({
    required this.imageUrl,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            role,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
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
