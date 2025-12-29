import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LevelProgressBottomSheet extends StatelessWidget {
  const LevelProgressBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Tinggi 85% layar
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // --- Handle Bar (Garis kecil di atas) ---
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
                            "1",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Roboto', // Pastikan font tebal
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Info XP & Progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Scoe", // Sesuai typo di gambar "Scoe" -> Score
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C314A),
                              ),
                            ),
                            const Text(
                              "XP 60",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Basic Planner",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C314A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Progress Bar Custom
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: 0.6, // 60% Progress
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
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You need 40 more XP to up your Badge's!",
                    style: TextStyle(color: Color(0xFF1C314A), fontSize: 14),
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
                  // Card Your Review
                  _buildReviewCard(
                    image: 'assets/images/placeholder_nature.jpg', // Ganti dengan URL/Asset Anda
                    title: "The Getaway",
                    desc: "My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...",
                    location: "Bedugul - Gianyar",
                    stars: 5,
                    isDeletable: true,
                  ),
                  // Card Duplicate (Sesuai gambar ada potongan card di bawahnya)
                  Transform.translate(
                    offset: const Offset(0, -10), // Efek tumpuk sedikit
                    child: Opacity(
                      opacity: 0.5,
                      child: _buildReviewCard(
                        image: 'assets/images/placeholder_nature.jpg',
                        title: "The Getaway",
                        desc: "My own schedule trip to get to somewhere full with",
                        location: "",
                        stars: 0,
                        isDeletable: false,
                        mini: true,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),

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
                  _buildReviewerCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Card untuk "Your Review" ---
  Widget _buildReviewCard({
    required String image,
    required String title,
    required String desc,
    required String location,
    required int stars,
    required bool isDeletable,
    bool mini = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
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
              color: Colors.grey[300], // Placeholder color
              // child: Image.network(image, fit: BoxFit.cover), // Gunakan ini jika ada gambar asli
              child: const Icon(Icons.image, color: Colors.grey),
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
                if (!mini) ...[
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
                        Text(
                          location,
                          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
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
                ]
              ],
            ),
          ),
          // Delete Icon
          if (isDeletable)
            const Icon(Icons.delete_outline, size: 20, color: Color(0xFF1C314A)),
        ],
      ),
    );
  }

  // --- WIDGET: Card untuk "Those Who Review You" ---
  Widget _buildReviewerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/images/user_placeholder.png'), // Ganti dengan asset Anda
                backgroundColor: Colors.grey, // Fallback
              ),
              const SizedBox(height: 8),
              const Text(
                "Jackson",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1C314A),
                ),
              ),
              const Text(
                "Traveller",
                style: TextStyle(
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
                      children: List.generate(5, (index) => const Icon(Icons.star_rounded, size: 18, color: Colors.amber)),
                    ),
                    const Icon(Icons.delete, size: 18, color: Color(0xFF1C314A)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "The Scenery is cute, the place is comfy, the people are very friendly, i came here with my family, and we feel very nice being here",
                  style: TextStyle(
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