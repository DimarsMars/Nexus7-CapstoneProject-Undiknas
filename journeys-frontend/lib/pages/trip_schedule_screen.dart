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

  final LatLng currentLocation = LatLng(-8.670458, 115.212629); // Denpasar
  final LatLng destination = LatLng(-8.374090, 115.167118); // Bedugul

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
      appBar: AppBar(
        title: const Text("Trip Schedule"),
      ),
      body: Stack(
        children: [
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
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  Marker(
                    point: destination,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ],
              ),

              /// CURRENT LOCATION
              const CurrentLocationLayer(),
            ],
          ),

          /// BOTTOM INFO
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Location : Denpasar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Going to : Bedugul - Villa Oprek"),
                  const SizedBox(height: 4),
                  Text(
                    isArrived ? "Status : Arrived" : "est ~50km left",
                    style: TextStyle(
                      color: isArrived ? Colors.green : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isArrived ? null : onArrived,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Arrived"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPause,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isPaused ? Colors.orange : Colors.blue,
                          ),
                          child: Text(isPaused ? "Resume" : "Pause"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Next Location",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ListTile(
                    leading: const Icon(Icons.place),
                    title: const Text("Serenity Oasis Resort"),
                    subtitle: const Text("Resort"),
                    trailing: const Icon(Icons.bookmark_border),
                    onTap: () =>
                        onNextLocation("Serenity Oasis Resort"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.place),
                    title: const Text("Batur Spring"),
                    subtitle: const Text("Tourist spot"),
                    trailing: const Icon(Icons.bookmark_border),
                    onTap: () => onNextLocation("Batur Spring"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
