import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:journeys/pages/bookmark_screen.dart';
import 'package:geolocator/geolocator.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  // OPENROUTESERVICE API KEY
  static const String orsApiKey = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQ1NmVlYzAzODhmMjQyYTU4YzNlYzFjNjcyZmJmOWNmIiwiaCI6Im11cm11cjY0In0=";

  final MapController mapController = MapController();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController doingController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  LatLng currentLocation = const LatLng(-8.436697, 115.279947);
  Marker? selectedMarker;

  String? selectedCategory;
  final List<String> categories = [
    "Food",
    "Adventure",
    "Relax",
    "Culture",
    "Shopping",
  ];

  // ===================== SEARCH LOCATION ======================
  Future<void> searchLocation() async {
    if (addressController.text.isEmpty) return;

    final url = Uri.parse(
      "https://api.openrouteservice.org/geocode/search?api_key=$orsApiKey&text=${addressController.text}",
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["features"].isEmpty) {
        throw Exception("Not found");
      }

      final coords = data["features"][0]["geometry"]["coordinates"];
      final lat = coords[1];
      final lon = coords[0];

      setState(() {
        currentLocation = LatLng(lat, lon);
        selectedMarker = Marker(
          point: currentLocation,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, size: 40, color: Colors.red),
        );
      });

      mapController.move(currentLocation, 15);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi tidak ditemukan")),
      );
    }
  }

  // ===================== ADD ROUTE ======================
  void addRoute() {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data route terlebih dahulu")),
      );
      return;
    }

    // simulasi simpan data (nanti bisa ke backend / database)
    debugPrint("=== ROUTE DATA ===");
    debugPrint("Title: ${titleController.text}");
    debugPrint("Description: ${descController.text}");
    debugPrint("Address: ${addressController.text}");
    debugPrint("Doing: ${doingController.text}");
    debugPrint("Tags: ${tagsController.text}");
    debugPrint("Category: $selectedCategory");
    debugPrint("Location: ${currentLocation.latitude}, ${currentLocation.longitude}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Route berhasil ditambahkan")),
    );

    clearAll();
  }

  // ===================== CLEAR FORM ======================
  void clearAll() {
    titleController.clear();
    descController.clear();
    addressController.clear();
    doingController.clear();
    tagsController.clear();
    selectedCategory = null;
    setState(() {});
  }

  // ===================== ADD CATEGORY ======================
  void addMoreCategory() {
    final TextEditingController catController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(hintText: "Nama kategori"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (catController.text.isNotEmpty) {
                setState(() {
                  categories.add(catController.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ========================== UI ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          "Forge Your Route",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            inputField(titleController, "Add title"),
            const SizedBox(height: 12),
            inputField(descController, "Add Description"),
            const SizedBox(height: 15),

            // MAP
            Container(
              height: 230,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.journeys",
                    ),
                    MarkerLayer(
                      markers: [
                        selectedMarker ??
                            Marker(
                              point: currentLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, size: 40, color: Colors.blue),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            inputField(addressController, "Alamat lokasi", isRefresh: false),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: searchLocation,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xff1A3250),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 15),
            inputField(doingController, "What are you doing"),
            const SizedBox(height: 12),
            inputField(tagsController, "#Tags (diketik sesuai database)"),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                mainButton("Add Route", addRoute),
                mainButton("Bookmark's", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookmarkScreen()),
                  );
                }),
              ],
            ),

            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Select Categories"),
                  value: selectedCategory,
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                ),
              ),
            ),

            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              onPressed: addMoreCategory,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text("Add more Categories"), SizedBox(width: 10), Icon(Icons.add, size: 20)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= REUSABLE =========================
  Widget inputField(TextEditingController c, String hint, {bool isRefresh = true}) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        suffixIcon: isRefresh
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => c.clear(),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget mainButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1A3250),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
    );
  }
}
