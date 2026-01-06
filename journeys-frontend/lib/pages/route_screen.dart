import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:journeys/pages/bookmark_screen.dart';
import 'package:journeys/services/api_service.dart';
import 'package:latlong2/latlong.dart';


class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  // ================= CONFIG =================
  static const String orsApiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQ1NmVlYzAzODhmMjQyYTU4YzNlYzFjNjcyZmJmOWNmIiwiaCI6Im11cm11cjY0In0=";

@override
void initState() {
  super.initState();
  fetchCategories();
}

Future<void> fetchCategories() async {
  try {
    final cats = await ApiService().getCategories();
    setState(() {
      categories.clear();
      categories.addAll(cats.map((cat) => cat.name));
    });
  } catch (e) {
    debugPrint("Fetch categories error: $e");
  }
}


Future<void> pickImage(ImageSource source, int index) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: source,
    imageQuality: 80,
  );

  if (pickedFile == null) return;

  Uint8List? bytes;
String? path;

if (kIsWeb) {
  bytes = await pickedFile.readAsBytes();
  path = pickedFile.name; // nama file, bukan path
} else {
  bytes = null;
  path = pickedFile.path;
}

setState(() {
  routes[index]["image"] = {
    "path": path,
    "bytes": bytes,       // ← simpan bytes di web
    "isWeb": kIsWeb,
  };
});


  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Image selected: ${pickedFile.path}")),
  );
}


Future<String?> getFirebaseToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return await user.getIdToken();
}

  final MapController mapController = MapController();
  
  // ✅ CONTROLLER UNTUK PLAN
final planTitleController = TextEditingController();
final planDescController = TextEditingController();

// ✅ CONTROLLER UNTUK ROUTE
final titleController = TextEditingController();
final descController = TextEditingController();

  final addressController = TextEditingController();
  final doingController = TextEditingController();
  

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
        hint: const Text("Status"),
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
  bool isCategoryDropdownOpen = false;
final List<String> selectedCategories = [];
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

void showAddImageDialog(int index) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pick from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.gallery, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () async {
                Navigator.pop(context);
                await pickImage(ImageSource.camera, index);
              },
            ),
          ],
        ),
      );
    },
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
  routePoints.clear();
  routePoints.addAll(
    routes.map((r) => r["latlng"] as LatLng),
  );
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
      "?api_key=$orsApiKey&text=${addressController.text}",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);
    final coords = data["features"][0]["geometry"]["coordinates"];

   setState(() {
  previewPoint = LatLng(coords[1], coords[0]);
  mapCenter = previewPoint!;
});

await reverseGeocode(previewPoint!);


    mapController.move(mapCenter, 15);
  }

  Future<void> reverseGeocode(LatLng latlng) async {
    final url =
        "https://api.openrouteservice.org/geocode/reverse"
        "?api_key=$orsApiKey&point.lon=${latlng.longitude}&point.lat=${latlng.latitude}";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    final props = data["features"][0]["properties"];

    setState(() {
  // 🟢 TITLE → nama tempat / jalan
  titleController.text =
      props["name"] ??
      props["street"] ??
      props["locality"] ??
      "";

  // 🟢 ADDRESS → alamat lengkap
  addressController.text = props["label"] ?? "";
});

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
  if (previewPoint == null) return;

  setState(() {
  routes.add({
    "title": titleController.text.isNotEmpty
    ? titleController.text
    : addressController.text.split(",").first,
      // ✅ FIXED: ambil dari input Title
    "address": addressController.text,
    "latlng": previewPoint!,
    "doing": doingController.text,
    "image": null,
  });


    routePoints.add(previewPoint!);
    previewPoint = null;
  });

  // Kosongkan input
  titleController.clear();
  addressController.clear();
  doingController.clear();

  fetchRoute();
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
  planTitleController.clear();
  planDescController.clear();

  titleController.clear();
  addressController.clear();
  doingController.clear();

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

Future<void> postRouteToBackend() async {
  if (routes.isEmpty) return;

  // 1. Convert routes & image to Base64
  final List<Map<String, dynamic>> convertedRoutes = [];

 for (int i = 0; i < routes.length; i++) {
  final r = routes[i];
  String base64Image = "";
  debugPrint("🔎 Route $i - Title: ${r["title"]}");
  debugPrint("🖼️ Route $i - Image: ${r["image"]}");

  if (r["image"] != null) {
    if (r["image"]["isWeb"] == true) {
      final bytes = r["image"]["bytes"] as Uint8List;
      base64Image = base64Encode(bytes);
      debugPrint("📦 Base64 (web) route $i length: ${base64Image.length}");
    } else if (r["image"]["path"] != null) {
      final path = r["image"]["path"];
      final bytes = await File(path).readAsBytes();
      base64Image = base64Encode(bytes);
      debugPrint("📦 Base64 (mobile) route $i length: ${base64Image.length}");
    }
  }

  convertedRoutes.add({
    "title": r["title"] ?? "",
    "description": r["doing"] ?? "",
    "address": r["address"] ?? "",
    "latitude": r["latlng"].latitude,
    "longitude": r["latlng"].longitude,
    "image": base64Image,
    "tags": [],
    "stepOrder": i,
  });
}


  try {
    // 2. POST Plan
    final allCategories = await ApiService().getCategories();
final selectedCategoryIds = allCategories
    .where((cat) => selectedCategories.contains(cat.name))
    .map((cat) => cat.id.toString())
    .toList();
  final newPlan = await ApiService().postPlanMultipart(
  title: planTitleController.text.trim(),
  description: planDescController.text.trim(),
  status: selectedValue ?? "",
  categories: selectedCategoryIds, // ← INI FIXED
  routes: convertedRoutes,
);


    if (newPlan != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plan berhasil dibuat!")),
      );

      // reset UI
      setState(() {
        routes.clear();
        routePoints.clear();
        routeGeometry.clear();
        previewPoint = null;
        selectedCategories.clear();
        selectedValue = null;
      });
      clearForm();
    }
  } catch (e) {
    debugPrint("Post Plan Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error saat membuat plan")),
    );
  }
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
          // ===== PLAN INFO =====
          inputField(planTitleController, "Add plan title"),
          inputField(planDescController, "Add plan description"),

          buildDropdown(),
          buildMap(),

          // ===== ROUTE INPUT =====


          // 🔍 ADDRESS (SEARCH / MAP)
          inputField(
            addressController,
            "Cari lokasi atau klik peta",
            isRefresh: false,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: searchLocation,
            ),
          ),

          // 📝 DESCRIPTION
          inputField(doingController, "What are you doing"),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              mainButton("Add Route", addRoute),
              // const SizedBox(width: 4,),
              mainButton("Bookmark's", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarkScreen()),
                );
              }),
            ],
          ),

          const SizedBox(height: 16),

          // ===== ROUTE LIST =====
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
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON / IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: r["image"] != null
                          ? (r["image"]["isWeb"] == true
                              ? Image.memory(
                                  r["image"]["bytes"],
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(r["image"]["path"]),
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                ))
                          : Container(
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
                    ),

                    const SizedBox(width: 12),

                    // CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE
                          Text(
                            "Lokasi ${index + 1}: ${r["title"] ?? "-"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ADDRESS
                          Text(
                            r["address"] ?? "-",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          // DESCRIPTION
                          if (r["doing"] != null &&
                              r["doing"].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              r["doing"],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // ACTION BUTTONS
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
                                onTap: () => showAddImageDialog(index),
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

          const SizedBox(height: 16),

          buildCategoryDropdown(),

          const SizedBox(height: 14),

          SizedBox(
  width: 123,
  height: 40,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff1A3250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    onPressed: postRouteToBackend,
    child: const Text(
      "Post Route",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)

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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🟦 Selected Chips + Add Button
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            // 🔘 Selected chips
            Expanded(
              child: Wrap(
  spacing: 6,
  runSpacing: 6,
  children: selectedCategories.isEmpty
      ? [
          const Text(
            "Add Categories",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          )
        ]
      : selectedCategories.map((cat) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffE8F0FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cat,
                  style: const TextStyle(
                    color: Color(0xff1A3250),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategories.remove(cat);
                    });
                  },
                  child: const Icon(Icons.close,
                      size: 16, color: Color(0xff1A3250)),
                ),
              ],
            ),
          );
        }).toList(),
),

            ),

            // ➕ Add toggle button
            GestureDetector(
              onTap: () {
                setState(() {
                  isCategoryDropdownOpen = !isCategoryDropdownOpen;
                });
              },
              child: const Icon(Icons.add, color: Color(0xff1A3250)),
            ),
          ],
        ),
      ),

      // 🔻 Dropdown List
      if (isCategoryDropdownOpen)
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: [
              ...categories.map((cat) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (!selectedCategories.contains(cat)) {
                        selectedCategories.add(cat);
                      }
                      selectedCategory = cat;
                      isCategoryDropdownOpen = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(cat),
                    ),
                  ),
                );
              }).toList(),

              const Divider(height: 1),

              InkWell(
                onTap: addMoreCategory,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}




  Widget inputField(
  TextEditingController controller,
  String hint, {
  bool isRefresh = true,
  Widget? suffixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    ),
    );
  }

  Widget mainButton(String text, VoidCallback onTap) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff1A3250),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // ← kecil = lebih kotak
      ),
    ),
    onPressed: onTap,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
}
