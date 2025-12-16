import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class TripScheduleScreen extends StatefulWidget {
  const TripScheduleScreen({super.key});

  @override
  State<TripScheduleScreen> createState() => _TripScheduleScreenState();
}

class _TripScheduleScreenState extends State<TripScheduleScreen> {
  final MapController mapController = MapController();

  bool isPaused = false;
  bool isArrived = false;

  final LatLng currentLocation = LatLng(-8.670458, 115.212629);
  final LatLng destination = LatLng(-8.374090, 115.167118);

  static const primaryBlue = Color(0xff1A73E8);
  static const darkBlue = Color(0xff174EA6);
  static const softGrey = Color(0xff6B7280);

  void onArrived() {
    setState(() => isArrived = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You have arrived 🎉")),
    );
  }

  void onPause() {
    setState(() => isPaused = !isPaused);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPaused ? "Trip paused ⏸️" : "Trip resumed ▶️"),
      ),
    );
  }

  void onNextLocation(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Navigate to $name")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Trip Schedule",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          /// ================= MAP =================
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.journeys',
              ),

              /// MARKER
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.navigation,
                      color: primaryBlue,
                      size: 30,
                    ),
                  ),
                  Marker(
                    point: destination,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 34,
                    ),
                  ),
                ],
              ),

              const CurrentLocationLayer(),
            ],
          ),

          /// ================= BOTTOM PANEL =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Location · Denpasar",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Going to · Bedugul - Villa Oprek",
                    style: TextStyle(color: softGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArrived ? "Arrived" : "est · ~50 km left",
                    style: TextStyle(
                      color:
                          isArrived ? Colors.green : softGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isArrived ? null : onArrived,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Arrived",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPause,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPaused ? Colors.orange : darkBlue,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isPaused ? "Resume" : "Pause",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    "Next Location",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// NEXT LOCATION CARD
                  buildNextLocation(
                    "Serenity Oasis Resort",
                    "Resort",
                  ),
                  buildNextLocation(
                    "Batur Spring",
                    "Tourist Spot",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextLocation(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: const Icon(Icons.place, color: primaryBlue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.bookmark_border, color: softGrey),
        onTap: () => onNextLocation(title),
      ),
    );
  }
}
