import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});
  
  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  GoogleMapController? mapController;
  TextEditingController addressController = TextEditingController();
  TextEditingController titleController = TextEditingController(text: "A Trip to Heaven");

  LatLng currentLocation = LatLng(-8.436697, 115.279947); // Tegalalang default
  Marker? selectedMarker;

  Future<void> searchLocation() async {
    String query = addressController.text;

    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      Location loc = locations.first;

      LatLng newPos = LatLng(loc.latitude, loc.longitude);

      setState(() {
        currentLocation = newPos;
        selectedMarker = Marker(
          markerId: MarkerId("selected_location"),
          position: newPos,
          infoWindow: InfoWindow(title: query),
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newPos, zoom: 15),
        ),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lokasi tidak ditemukan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back_ios),
        title: Text(
          "Forge Your Route",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== TITLE INPUT =====
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "A Trip to Heaven",
                suffixIcon: Icon(Icons.refresh),
                filled: true,
                fillColor: Color(0xffF2F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 15),

            // ===== MAP SECTION =====
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation,
                    zoom: 14,
                  ),
                  markers: selectedMarker != null
                      ? {selectedMarker!}
                      : {
                          Marker(
                            markerId: MarkerId("default"),
                            position: currentLocation,
                          )
                        },
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),
              ),
            ),

            SizedBox(height: 10),

            // ===== ADDRESS INPUT + BUTTON SEARCH =====
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: "Masukkan alamat...",
                      filled: true,
                      fillColor: Color(0xffF2F3F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10),

                InkWell(
                  onTap: searchLocation,
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xff1A3250),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                )
              ],
            ),

            SizedBox(height: 20),

            // ===== BUTTONS =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff1A3250),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {},
                  child: Text("Add Route"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff1A3250),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {},
                  child: Text("Bookmark's"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
