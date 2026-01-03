import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:http/http.dart' as http;

class TripScheduleScreen extends StatefulWidget {
  const TripScheduleScreen({super.key});

  @override
  State<TripScheduleScreen> createState() => _TripScheduleScreenState();
}

class _TripScheduleScreenState extends State<TripScheduleScreen> {
  final MapController mapController = MapController();

  static const primaryBlue = Color(0xff1A73E8);
  static const darkBlue = Color(0xff174EA6);
  static const softGrey = Color(0xff6B7280);

  bool isPaused = false;
  bool isArrived = false;

  /// CURRENT USER LOCATION (DUMMY / GPS)
  final LatLng currentLocation = LatLng(-8.670458, 115.212629);

  /// ROUTE STEPS
  List<Map<String, dynamic>> routeSteps = [];
  int currentStepIndex = 0;

  /// CURRENT DESTINATION
  LatLng? destination;

  // =================================================
  // INIT
  // =================================================
  @override
  void initState() {
    super.initState();
    fetchRouteSteps();
  }

  // =================================================
  // GET ROUTE STEPS (MULTIPLE)
  // =================================================
  Future<void> fetchRouteSteps() async {
    final response = await http.get(
      Uri.parse("http://localhost:8080/plans/route/1"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      /// JIKA BACKEND SUDAH ARRAY
      final List data = json['data'] is List
          ? json['data']
          : [json['data']];

      data.sort((a, b) =>
          a['step_order'].compareTo(b['step_order']));

      setState(() {
        routeSteps = List<Map<String, dynamic>>.from(data);
        destination = LatLng(
          routeSteps[0]['latitude'],
          routeSteps[0]['longitude'],
        );
      });
    } else {
      debugPrint("ROUTE ERROR ${response.statusCode}");
    }
  }

  // =================================================
  // ARRIVED → NEXT STEP
  // =================================================
  void onArrived() {
    if (currentStepIndex < routeSteps.length - 1) {
      setState(() {
        currentStepIndex++;
        destination = LatLng(
          routeSteps[currentStepIndex]['latitude'],
          routeSteps[currentStepIndex]['longitude'],
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Arrived at ${routeSteps[currentStepIndex - 1]['title']}",
          ),
        ),
      );
    } else {
      setState(() => isArrived = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip Completed 🎉")),
      );
    }
  }

  void onPause() {
    setState(() => isPaused = !isPaused);
  }

  void onNextLocation(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Navigate to $name")),
    );
  }

  // =================================================
  // UI
  // =================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Trip Schedule",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: destination == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
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

                    /// MARKERS
                    MarkerLayer(
                      markers: [
                        /// CURRENT LOCATION
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

                        /// ALL STEPS
                        ...routeSteps.map(
                          (step) => Marker(
                            point: LatLng(
                              step['latitude'],
                              step['longitude'],
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 34,
                            ),
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
                  child: buildBottomPanel(),
                ),
              ],
            ),
    );
  }

  // =================================================
  // BOTTOM PANEL
  // =================================================
  Widget buildBottomPanel() {
    final currentStep = routeSteps[currentStepIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Location",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Going to · ${currentStep['title']}",
            style: const TextStyle(color: softGrey),
          ),
          const SizedBox(height: 4),
          Text(
            isArrived ? "Arrived" : "Step ${currentStepIndex + 1} of ${routeSteps.length}",
            style: TextStyle(
              color: isArrived ? Colors.green : softGrey,
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
                      borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(12),
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
            "Next Locations",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          /// NEXT STEPS LIST
          ...routeSteps
              .skip(currentStepIndex + 1)
              .map(
                (step) => buildNextLocation(
                  step['title'],
                  step['tags'] != null && step['tags'].isNotEmpty
                      ? step['tags'][0]
                      : '',
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
            const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => onNextLocation(title),
      ),
    );
  }
}
