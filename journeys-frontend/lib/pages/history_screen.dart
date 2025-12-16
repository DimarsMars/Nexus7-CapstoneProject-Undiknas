import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _MyHistoryScreen();
}

class _MyHistoryScreen extends State<HistoryScreen> {

  static const Color _darkBlue = Color(0xFF1C314A);
  static const Color _darkGrey = Color(0xFF1C314A);
  static const Color _lightGreyText = Colors.black;

  static const Color _backgroundColor = Color(0xFFe9ebee);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('History'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: YOUR TRIP NOW ---
                  _buildSectionHeader('Your trip now', 'Cancel Trip'),
                  const SizedBox(height: 16),
                  _buildCurrentTripCard(),

                  const SizedBox(height: 32),

                  // --- SECTION 2: FAVOURITES ---
                  _buildSectionHeader('Favourites', 'Remove all'),
                  const SizedBox(height: 16),
                  // Daftar kartu
                  _buildTripCard(
                    title: 'The Getaway',
                    description:
                        'My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...',
                    location: 'Bedugul - Gianyar',
                    icon: Icons.bookmark,
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    title: 'My Life My Rule',
                    description:
                        'My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...',
                    location: 'Bedugul - Gianyar',
                    icon: Icons.bookmark,
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION 3: YOUR PAST TRIP'S ---
                  _buildSectionHeader('Your past trip\'s', 'Remove all'),
                  const SizedBox(height: 16),
                  // Daftar kartu...
                  _buildTripCard(
                    title: 'The Getaway',
                    description:
                        'My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...',
                    location: 'Bedugul - Gianyar',
                    icon: Icons.delete_outline, // Ikon Delete
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    title: 'My Life My Rule',
                    description:
                        'My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...',
                    location: 'Bedugul - Gianyar',
                    icon: Icons.delete_outline, // Ikon Delete
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    title: 'The Getaway',
                    description:
                        'My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...',
                    location: 'Bedugul - Gianyar',
                    icon: Icons.delete_outline, // Ikon Delete
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String buttonText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Judul Section
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3651),
          ),
        ),
        // Tombol Aksi
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildCurrentTripCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        // Style dari profile_screen.dart
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[500],
              size: 40,
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seasonal Trip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'My own schedule trip to get to somewhere full with guidance to someplace i like but i can go anywhere...',
                  style: TextStyle(fontSize: 12, color: _lightGreyText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: _lightGreyText),
                    const SizedBox(width: 4),
                    Text(
                      'Bedugul - Gianyar',
                      style: TextStyle(fontSize: 12, color: _lightGreyText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Panah
          Container(
            decoration: BoxDecoration(
              color: _darkGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk kartu "Favourites" dan "Past Trip's"
  Widget _buildTripCard({
    required String title,
    required String description,
    required String location,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[500],
              size: 40,
            ),
          ),
          const SizedBox(width: 12),
          // Kolom Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: _lightGreyText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: _lightGreyText),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(fontSize: 12, color: _lightGreyText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Ikon (Bookmark/Delete)
          IconButton(
            onPressed: () {},
            icon: Icon(icon, color: _darkGrey, size: 24),
          ),
        ],
      ),
    );
  }
}

