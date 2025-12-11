import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:journeys/pages/bookmark_screen.dart'; // GANTI sesuai file kamu

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  GoogleMapController? mapController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController doingController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  LatLng currentLocation = const LatLng(-8.436697, 115.279947); // Default Tegalalang
  Marker? selectedMarker;

  String? selectedCategory;

  Future<void> searchLocation() async {
    if (addressController.text.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(addressController.text);
      Location loc = locations.first;

      LatLng newPos = LatLng(loc.latitude, loc.longitude);

      setState(() {
        currentLocation = newPos;
        selectedMarker = Marker(
          markerId: const MarkerId("selected"),
          position: newPos,
          infoWindow: InfoWindow(title: addressController.text),
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPos, 15),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi tidak ditemukan")),
      );
    }
  }

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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            // TITLE FIELD
            inputField(titleController, "Add title"),
            const SizedBox(height: 12),

            // DESCRIPTION FIELD
            inputField(descController, "Add Description"),
            const SizedBox(height: 15),

            // MAP SECTION
            Container(
              height: 230,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => mapController = controller,
                  markers: selectedMarker != null
                      ? {selectedMarker!}
                      : {
                          Marker(
                            markerId: const MarkerId("default"),
                            position: currentLocation,
                          )
                        },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ADDRESS FIELD
            inputField(addressController, "Alamat lokasi"),
            const SizedBox(height: 10),

            // SEARCH ADDRESS BUTTON
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

            // WHAT ARE YOU DOING
            inputField(doingController, "What are you doing"),
            const SizedBox(height: 12),

            // TAGS
            inputField(tagsController, "#Tags (diketik sesuai database)"),
            const SizedBox(height: 18),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                mainButton("Add Route", () {}),
                mainButton("Bookmark's", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookmarkScreen())
                  );
                }),
              ],
            ),

            const SizedBox(height: 25),

            // CATEGORY DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Select Categories"),
                  value: selectedCategory,
                  items: [
                    "Food",
                    "Adventure",
                    "Relax",
                    "Culture",
                    "Shopping",
                  ].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ADD MORE CATEGORY
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
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Add more Categories"),
                  SizedBox(width: 10),
                  Icon(Icons.add, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= WIDGET REUSABLE =========================

  Widget inputField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        suffixIcon: const Icon(Icons.refresh),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}
