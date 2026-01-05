// Mengimpor paket dasar Flutter dan material design
import 'package:flutter/material.dart';
// Mengimpor model data untuk riwayat perjalanan dan favorit
import 'package:journeys/models/past_trip_model.dart';
import 'package:journeys/models/favorite_trip_model.dart';
// Mengimpor layanan API untuk komunikasi dengan server
import 'package:journeys/services/api_service.dart';
// Mengimpor paket untuk konversi data seperti base64
import 'dart:convert';

// Widget utama HistoryScreen sebagai StatefulWidget karena memiliki data yang dinamis
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _MyHistoryScreen();
}

// State untuk mengelola logika dan data pada halaman History
class _MyHistoryScreen extends State<HistoryScreen> {
  // Inisialisasi layanan API
  final ApiService _apiService = ApiService();

  // State untuk mengelola data Past Trips (Riwayat Perjalanan)
  List<PastTripModel> _pastTrips = [];
  bool _isLoadingPastTrips = true;
  String? _errorPastTrips;

  // State untuk mengelola data Favorite Trips (Perjalanan Favorit)
  List<FavoriteTripModel> _favoriteTrips = [];
  bool _isLoadingFavorites = true;
  String? _errorFavorites;

  // Fungsi lifecycle yang dipanggil pertama kali saat halaman dimuat
  @override
  void initState() {
    super.initState();
    _fetchPastTrips(); // Mengambil data riwayat perjalanan
    _fetchFavoriteTrips(); // Mengambil data favorit
  }

  // Fungsi asinkron untuk mengambil data riwayat perjalanan dari API
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

  // Fungsi asinkron untuk mengambil data perjalanan favorit dari API
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

  // Menangani penghapusan item riwayat perjalanan dengan dialog konfirmasi
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
        _fetchPastTrips(); // Memperbarui daftar setelah dihapus
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

  // Menangani penghapusan item dari daftar favorit
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
        _fetchFavoriteTrips(); // Memperbarui daftar favorit
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

  // Menangani penghapusan seluruh daftar favorit sekaligus
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
        // Membuat daftar proses (Future) untuk menghapus tiap item favorit
        final List<Future> deleteFutures = _favoriteTrips.map((trip) {
          return _apiService.removeFavoriteTrip(trip.favoriteId);
        }).toList();

        // Menjalankan semua proses penghapusan secara paralel
        await Future.wait(deleteFutures);

        _fetchFavoriteTrips(); // Memperbarui UI
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

  // Definisi konstanta warna untuk tema halaman
  static const Color _darkBlue = Color(0xFF1C314A);
  static const Color _darkGrey = Color(0xFF1C314A);
  static const Color _lightGreyText = Colors.black;
  static const Color _backgroundColor = Color(0xFFe9ebee);

  // Widget builder utama untuk merender UI halaman
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
                  // --- SEKSI 1: PERJALANAN AKTIF SAAT INI ---
                  _buildSectionHeader('Your trip now', 'Cancel Trip'),
                  const SizedBox(height: 16),
                  _buildCurrentTripCard(),

                  const SizedBox(height: 32),

                  // --- SEKSI 2: DAFTAR FAVORIT ---
                  _buildSectionHeader('Favourites', 'Remove all',
                      onPressed: _handleRemoveAllFavorites),
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
                                      location: fav.plan.routes.isNotEmpty
                                          ? fav.plan.routes.first.address
                                          : 'No location',
                                      icon: Icons.favorite,
                                      banner: fav.plan.bannerBase64,
                                      onIconPressed: () => _handleRemoveFavorite(fav.favoriteId),
                                      iconColor: Colors.red,
                                    );
                                  },
                                ),

                  const SizedBox(height: 32),

                  // --- SEKSI 3: RIWAYAT PERJALANAN MASA LALU ---
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
                                      location: trip.routes.isNotEmpty
                                          ? trip.routes.first.address
                                          : 'No location',
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

  // Widget Helper untuk membangun bagian Header setiap seksi
  Widget _buildSectionHeader(String title, String buttonText, {VoidCallback? onPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3651),
          ),
        ),
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

  // Widget Helper untuk membangun kartu perjalanan yang sedang berlangsung (hardcoded placeholder)
  Widget _buildCurrentTripCard() {
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
          Container(
            decoration: BoxDecoration(
              color: _darkGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper umum untuk membangun kartu daftar "Favourites" dan "Past Trips"
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 40),
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 12),
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
          IconButton(
            onPressed: onIconPressed,
            icon: Icon(icon, color: iconColor ?? _darkGrey, size: 24),
          ),
        ],
      ),
    );
  }
}