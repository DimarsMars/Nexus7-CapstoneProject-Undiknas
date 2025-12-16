import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:journeys/pages/bookmark_screen.dart';
import 'package:journeys/pages/trip_schedule_screen.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  static const String orsApiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQ1NmVlYzAzODhmMjQyYTU4YzNlYzFjNjcyZmJmOWNmIiwiaCI6Im11cm11cjY0In0=";

  final MapController mapController = MapController();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final doingController = TextEditingController();
  final tagsController = TextEditingController();

  LatLng currentLocation = const LatLng(-8.436697, 115.279947);

  String? selectedCategory;
  final List<String> categories = [
    "Food",
    "Adventure",
    "Relax",
    "Culture",
    "Shopping",
  ];

  final List<Map<String, dynamic>> routes = [];

  /// 🔥 SEMUA TITIK ROUTE
  final List<LatLng> routePoints = [];

  // ================= SEARCH LOCATION =================
  Future<void> searchLocation() async {
    if (addressController.text.isEmpty) return;

    final url = Uri.parse(
      "https://api.openrouteservice.org/geocode/search?api_key=$orsApiKey&text=${addressController.text}",
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      final coords = data["features"][0]["geometry"]["coordinates"];

      setState(() {
        currentLocation = LatLng(coords[1], coords[0]);
      });

      mapController.move(currentLocation, 15);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi tidak ditemukan")),
      );
    }
  }

  // ================= ADD ROUTE =================
  void addRoute() {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data route")),
      );
      return;
    }

    setState(() {
      routes.add({
        "title": titleController.text,
        "address": addressController.text,
        "latlng": currentLocation,
      });

      /// 🔥 SIMPAN TITIK & NYAMBUNG
      routePoints.add(currentLocation);
    });

    clearForm();
  }

  // ================= POST ROUTE =================
  void postRoute() {
    if (routes.isEmpty) return;

    setState(() {
      routes.clear();
      routePoints.clear();
      currentLocation = const LatLng(-8.436697, 115.279947);
    });

    mapController.move(currentLocation, 14);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Route berhasil di-post")),
    );
  }

  void clearForm() {
    titleController.clear();
    descController.clear();
    addressController.clear();
    doingController.clear();
    tagsController.clear();
    selectedCategory = null;
  }

  // ================= ADD CATEGORY POPUP =================
  void addMoreCategory() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Category name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  categories.add(controller.text);
                  selectedCategory = controller.text;
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text("Forge Your Route",
            style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            inputField(titleController, "Add title"),
            inputField(descController, "Add Description"),
            buildMap(),
            inputField(addressController, "Alamat lokasi",
                isRefresh: false),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: searchLocation,
              ),
            ),

            inputField(doingController, "What are you doing"),
            inputField(tagsController, "#Tags"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                mainButton("Add Route", addRoute),
                mainButton("Bookmark's", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BookmarkScreen()),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            /// ===== ROUTE LIST =====
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final r = routes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TripScheduleScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r["address"] ?? "-",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              routes.removeAt(index);
                              routePoints.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            buildCategoryDropdown(),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: addMoreCategory,
              icon: const Icon(Icons.add),
              label: const Text("Add more Categories"),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1A3250),
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: postRoute,
              child: const Text("Post Route",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MAP =================
  Widget buildMap() {
    return Container(
      height: 230,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation,
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),

          /// 🔥 GARIS ROUTE
          if (routePoints.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 4,
                  color: Colors.blue,
                ),
              ],
            ),

          /// 🔥 SEMUA MARKER
          MarkerLayer(
            markers: routePoints
                .map(
                  (p) => Marker(
                    point: p,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 36),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET =================
  Widget buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text("Select Categories"),
          value: selectedCategory,
          items: categories
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) =>
              setState(() => selectedCategory = v),
        ),
      ),
    );
  }

  Widget inputField(TextEditingController c, String hint,
      {bool isRefresh = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          suffixIcon: isRefresh
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: c.clear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget mainButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1A3250),
      ),
      onPressed: onTap,
      child:
          Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
