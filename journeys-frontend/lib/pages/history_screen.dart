import 'package:flutter/material.dart';
import 'package:journeys/models/past_trip_model.dart';
import 'package:journeys/models/favorite_trip_model.dart';
import 'package:journeys/services/api_service.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _MyHistoryScreen();
}

class _MyHistoryScreen extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  
  // State for Past Trips
  List<PastTripModel> _pastTrips = [];
  bool _isLoadingPastTrips = true;
  String? _errorPastTrips;

  // State for Favorite Trips
  List<FavoriteTripModel> _favoriteTrips = [];
  bool _isLoadingFavorites = true;
  String? _errorFavorites;

  @override
  void initState() {
    super.initState();
    _fetchPastTrips();
    _fetchFavoriteTrips();
  }

  Future<void> _fetchPastTrips() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoadingPastTrips = true;
        _errorPastTrips = null;
      });
      final trips = await _apiService.getPastTrips();
      if (mounted) {
        setState(() {
          _pastTrips = trips;
          _isLoadingPastTrips = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorPastTrips = 'Failed to load past trips: $e';
          _isLoadingPastTrips = false;
        });
      }
    }
  }

    Future<void> _fetchFavoriteTrips() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoadingFavorites = true;
        _errorFavorites = null;
      });
      final trips = await _apiService.getFavoriteTrips();
      if (mounted) {
        setState(() {
          _favoriteTrips = trips;
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorFavorites = 'Failed to load favorite trips: $e';
          _isLoadingFavorites = false;
        });
      }
    }
  }

  Future<void> _handleDeleteHistory(int progressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: const Text('Are you sure you want to delete this trip history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deletePastTrip(progressId);
        _fetchPastTrips(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip history deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete history: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleRemoveFavorite(int favoriteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: const Text('Are you sure you want to remove this from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.removeFavoriteTrip(favoriteId);
        _fetchFavoriteTrips(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from favorites')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove favorite: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleRemoveAllFavorites() async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove All Favorites'),
        content: const Text('Are you sure you want to remove all your favorite trips?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
     if (confirm == true) {
        try {
          // Create a list of futures to delete each favorite
          final List<Future> deleteFutures = _favoriteTrips.map((trip) {
            return _apiService.removeFavoriteTrip(trip.favoriteId);
          }).toList();

          // Wait for all delete operations to complete
          await Future.wait(deleteFutures);

          _fetchFavoriteTrips(); // Refresh the list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All favorites have been removed')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred while removing favorites: $e')),
            );
          }
        }
    }
  }

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
                  _buildSectionHeader('Favourites', 'Remove all', onPressed: _handleRemoveAllFavorites),
                  const SizedBox(height: 16),
                  _isLoadingFavorites
                      ? const Center(child: CircularProgressIndicator())
                      : _errorFavorites != null
                          ? Center(child: Text(_errorFavorites!))
                          : _favoriteTrips.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text('You haven\'t favorited any trips yet.'),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _favoriteTrips.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final fav = _favoriteTrips[index];
                                    return _buildTripCard(
                                      title: fav.plan.title,
                                      description: fav.plan.description,
                                      location: fav.plan.routes.isNotEmpty ? fav.plan.routes.first.address : 'No location',
                                      icon: Icons.favorite,
                                      banner: fav.plan.bannerBase64,
                                      onIconPressed: () => _handleRemoveFavorite(fav.favoriteId),
                                      iconColor: Colors.red,
                                    );
                                  },
                                ),

                  const SizedBox(height: 32),

                  // --- SECTION 3: YOUR PAST TRIP'S ---
                  _buildSectionHeader('Your past trip\'s', 'Remove all'),
                  const SizedBox(height: 16),
                  _isLoadingPastTrips
                      ? const Center(child: CircularProgressIndicator())
                      : _errorPastTrips != null
                          ? Center(child: Text(_errorPastTrips!))
                          : _pastTrips.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text('No travel history found.'),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _pastTrips.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final trip = _pastTrips[index];
                                    return _buildTripCard(
                                      title: trip.title,
                                      description: trip.description,
                                      location: trip.routes.isNotEmpty ? trip.routes.first.address : 'No location',
                                      icon: Icons.delete_outline,
                                      banner: trip.banner,
                                      onIconPressed: () => _handleDeleteHistory(trip.progressId),
                                      iconColor: _darkGrey,
                                    );
                                  },
                                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

  Widget _buildSectionHeader(String title, String buttonText, {VoidCallback? onPressed}) {
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
          onPressed: onPressed,
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
    String? banner,
    VoidCallback? onIconPressed,
    Color? iconColor,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: banner != null && banner.isNotEmpty
                  ? Image.memory(
                      base64Decode(banner.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40),
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
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
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 12, color: _lightGreyText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Ikon (Bookmark/Delete)
          IconButton(
            onPressed: onIconPressed,
            icon: Icon(icon, color: iconColor ?? _darkGrey, size: 24),
          ),
        ],
      ),
    );
  }
}