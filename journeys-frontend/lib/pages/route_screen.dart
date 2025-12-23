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
  // ================= CONFIG =================
  static const String orsApiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQ1NmVlYzAzODhmMjQyYTU4YzNlYzFjNjcyZmJmOWNmIiwiaCI6Im11cm11cjY0In0=";

  final MapController mapController = MapController();

  // ================= CONTROLLERS =================
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final doingController = TextEditingController();
  final tagsController = TextEditingController();

  // ================= STATE =================
  LatLng mapCenter = const LatLng(-8.436697, 115.279947);

  LatLng? previewPoint; // 🔵 preview marker
  final List<LatLng> routePoints = []; // 🔴 marker fix
  final List<LatLng> routeGeometry = []; // 🟣 polyline jalan

  final List<Map<String, dynamic>> routes = [];

  String? selectedValue;
  final List<String> dropdownItems = [
  "Family",
  "Friends",
  "Solo Trip",
  "Couple",
  "Adventure",
];

Widget buildDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        hint: const Text("Select Category"),
        value: selectedValue,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        items: dropdownItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
      ),
    ),
  );
}

  String? selectedCategory;
  final List<String> categories = [
    "Food",
    "Adventure",
    "Relax",
    "Culture",
    "Shopping",
  ];

void showEditRouteDialog(int index) {
  final titleEdit = TextEditingController(text: routes[index]["title"]);
  final addressEdit = TextEditingController(text: routes[index]["address"]);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Route"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleEdit,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: addressEdit,
            decoration: const InputDecoration(labelText: "Address"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              routes[index]["title"] = titleEdit.text;
              routes[index]["address"] = addressEdit.text;
            });
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

void showAddImageDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Add Image"),
      content: const Text("Feature add image coming soon 📸"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

void showDeleteConfirmDialog(int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Route"),
      content: const Text("Are you sure you want to delete this route?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            setState(() {
              routes.removeAt(index);
              routePoints.removeAt(index);
            });
            fetchRoute();
            Navigator.pop(context);
          },
          child: const Text("Delete"),
        ),
      ],
    ),
  );
}


  Widget _actionButton({
  required String text,
  required Color color,
  required Color textColor,
  required VoidCallback onTap,
  IconData? icon,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}


  // ================= SEARCH LOCATION =================
  Future<void> searchLocation() async {
    if (addressController.text.isEmpty) return;

    final url = Uri.parse(
      "https://api.openrouteservice.org/geocode/search"
      "?api_key=$orsApiKey"
      "&text=${addressController.text}",
    );

    try {
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      final coords = data["features"][0]["geometry"]["coordinates"];

      setState(() {
        previewPoint = LatLng(coords[1], coords[0]);
        mapCenter = previewPoint!;
      });

      mapController.move(mapCenter, 15);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi tidak ditemukan")),
      );
    }
  }

  // ================= REVERSE GEOCODE =================
  Future<void> reverseGeocode(LatLng latlng) async {
    final url =
        "https://api.openrouteservice.org/geocode/reverse"
        "?api_key=$orsApiKey"
        "&point.lon=${latlng.longitude}"
        "&point.lat=${latlng.latitude}";

    try {
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      final props = data["features"][0]["properties"];

      setState(() {
        addressController.text = props["label"] ??
            "${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}";
      });
    } catch (_) {}
  }

  // ================= FETCH ROUTE =================
  Future<void> fetchRoute() async {
    if (routePoints.length < 2) return;

    final coords =
        routePoints.map((p) => [p.longitude, p.latitude]).toList();

    final response = await http.post(
      Uri.parse(
          "https://api.openrouteservice.org/v2/directions/driving-car/geojson"),
      headers: {
        "Authorization": orsApiKey,
        "Content-Type": "application/json",
      },
      body: jsonEncode({"coordinates": coords}),
    );

    final data = jsonDecode(response.body);
    final List geometry =
        data["features"][0]["geometry"]["coordinates"];

    setState(() {
      routeGeometry
        ..clear()
        ..addAll(geometry.map((c) => LatLng(c[1], c[0])));
    });
  }

  // ================= ADD ROUTE =================
  void addRoute() {
  if (previewPoint == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Klik peta atau cari lokasi dulu")),
    );
    return;
  }

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
      "latlng": previewPoint!,
    });

    routePoints.add(previewPoint!);
    mapCenter = previewPoint!;
    previewPoint = null;
  });

  // 🔥 LETAKKAN DI SINI
  fetchRoute();
  clearRouteForm(); // ✅ title & description TIDAK KEHAPUS
}
void clearRouteForm() {
  addressController.clear();
  doingController.clear();
  tagsController.clear();
  selectedCategory = null;
}


  // ================= POST ROUTE =================
  void postRoute() {
    if (routes.isEmpty) return;

    setState(() {
      routes.clear();
      routePoints.clear();
      routeGeometry.clear();
      previewPoint = null;
      mapCenter = const LatLng(-8.436697, 115.279947);
    });

    mapController.move(mapCenter, 14);

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

  // ================= ADD CATEGORY =================
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
        title: const Text(
          "Forge Your Route",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            inputField(titleController, "Add title"),
            inputField(descController, "Add Description"),
            buildDropdown(),
            buildMap(),
            inputField(addressController, "Cari lokasi atau klik peta",
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

            /// ROUTE LIST
            ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: routes.length,
  itemBuilder: (context, index) {
    final r = routes[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON KIRI
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffE8F0FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xff4B6CB7),
            ),
          ),

          const SizedBox(width: 12),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  "Lokasi ${index + 1} : ${r["title"] ?? "Lokasi"}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                /// SUBTITLE
                Text(
                  r["address"] ?? "-",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                /// ACTION BUTTONS
                Row(
                  children: [
                    _actionButton(
                      text: "Edit Route",
                      color: Colors.grey.shade200,
                      textColor: Colors.black,
                      onTap: () => showEditRouteDialog(index),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      text: "Add Image",
                      color: const Color(0xffE8F0FE),
                      textColor: const Color(0xff4B6CB7),
                     onTap: showAddImageDialog,
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      text: "Delete",
                      color: Colors.red,
                      textColor: Colors.white,
                      onTap: () => showDeleteConfirmDialog(index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
),

            const SizedBox(height: 12),
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
      height: 240,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: mapCenter,
          initialZoom: 14,
          onTap: (tapPosition, latlng) async {
            setState(() {
              previewPoint = latlng;
              mapCenter = latlng;
            });
            await reverseGeocode(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),

          /// ROUTE LINE
          if (routeGeometry.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routeGeometry,
                  strokeWidth: 6,
                  color: Colors.deepPurpleAccent,
                ),
              ],
            ),

          /// MARKERS
          MarkerLayer(
            markers: [
              ...routePoints.map(
                (p) => Marker(
                  point: p,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ),
              if (previewPoint != null)
                Marker(
                  point: previewPoint!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 36,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================
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
