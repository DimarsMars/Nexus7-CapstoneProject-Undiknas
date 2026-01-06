import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:journeys/services/api_service.dart';
import 'package:latlong2/latlong.dart';

class TripScheduleScreen extends StatefulWidget {
  final int planId;
  const TripScheduleScreen({super.key, required this.planId});

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
  bool isLoading = true;

  /// CURRENT LOCATION (realtime)
  LatLng? currentLocation;

  /// ROUTE STEPS
  List<Map<String, dynamic>> routeSteps = [];
  int currentStepIndex = 0;

  LatLng? destination;

  late StreamSubscription<Position> positionStream;


  // =================================================
  // INIT
  // =================================================
  @override
@override
void initState() {
  super.initState();
  _initializeAll();
}

Future<void> _initializeAll() async {
  await _initCurrentLocation();
  _startLocationUpdates();
  _loadTripSession();
}


void _startLocationUpdates() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }
  }

  positionStream = Geolocator.getPositionStream(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  ),
).listen((position) {
  final newLocation = LatLng(position.latitude, position.longitude);

  if (!mounted) return;

  setState(() {
    currentLocation = newLocation;
  });

  // Hanya move jika controller sudah siap dan context masih hidup
  try {
   try {
  mapController.move(newLocation, mapController.camera.zoom);
} catch (e) {
  debugPrint('MapController move error: $e');
}

  } catch (e) {
    debugPrint('MapController error: $e');
  }
});


}



  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  // =================================================
  // LOAD TRIP SESSION
  // =================================================
  Future<void> _loadTripSession() async {
    try {
      final session = await ApiService().getActiveTripSession();

      if (!mounted) return;

      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active trip found')),
        );
        Navigator.pop(context);
        return;
      }

      final int currentStepId = session['route_id'];
      final int planId = session['plan_id'];

      final planDetail = await ApiService().getPlanDetailForTrip(planId);
      final steps = planDetail?.routes ?? [];

      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No routes found in plan')),
        );
        Navigator.pop(context);
        return;
      }

      final index =
          steps.indexWhere((step) => step.routeId == currentStepId);

      if (index == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current step not found in plan')),
        );
        Navigator.pop(context);
        return;
      }

      setState(() {
        routeSteps = steps.map((e) => {
              'route_id': e.routeId,
              'step_order': e.stepOrder,
              'title': e.title,
              'latitude': e.latitude,
              'longitude': e.longitude,
              'tags': e.tags is List ? List<String>.from(e.tags) : <String>[],
              'image': e.imageBase64,
            }).toList();

        currentStepIndex = index;
        destination = LatLng(
          routeSteps[index]['latitude'],
          routeSteps[index]['longitude'],
        );
        isPaused = session['status'] == 'paused';
        isLoading = false;
      });
    } catch (e) {
      debugPrint('TripSchedule error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load trip')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _initCurrentLocation() async {
  try {
   LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied ||
    permission == LocationPermission.deniedForever) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    debugPrint('Location permission denied');
    return;
  }
}

final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.best,
);


   setState(() {
  currentLocation = LatLng(position.latitude, position.longitude);
});

// Langsung pindahkan map ke posisi awal
mapController.move(
  LatLng(position.latitude, position.longitude),
  12,
);

  } catch (e) {
    debugPrint('Failed to get initial location: $e');
  }
}


  // =================================================
  // ARRIVED
  // =================================================
  Future<void> onArrived() async {
  final currentStep = routeSteps[currentStepIndex];

  try {
    if (currentLocation == null) return;

    final response = await ApiService().verifyLocation(
      widget.planId,
      currentStep['step_order'],
      currentLocation!,
    );

    if (!mounted || response == null) return;

    if (response['next_route'] != null) {
      final next = response['next_route'];

      // 🔥 Tambahkan blok ini untuk langsung start trip berikutnya
      await ApiService().postTripSessionAction(
        planId: widget.planId,
        action: 'start',
        routeId: next['route_id'],
      );

      setState(() {
        currentStepIndex++;
        destination = LatLng(
          next['latitude'],
          next['longitude'],
        );

        // force update local route_id (untuk tombol pause/resume)
        routeSteps[currentStepIndex]['route_id'] = next['route_id'];
        isPaused = false; // reset pause status
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip Completed 🎉')),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        context.go('/home');
      }
    }
  } catch (e) {
    debugPrint('Verify location error: $e');
  }
}



  // =================================================
  // PAUSE / RESUME
  // =================================================
 Future<void> onPause() async {
  try {
    final action = isPaused ? 'resume' : 'pause';

    final currentStep = routeSteps[currentStepIndex];
    final routeId = currentStep['route_id'];

    final success = await ApiService().postTripSessionAction(
      planId: widget.planId, // ✅ PAKAI planId
      action: action,
      routeId: routeId,
    );

    if (!mounted) return;

    if (success) {
      setState(() => isPaused = !isPaused);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update trip status')),
      );
    }
  } catch (e) {
    debugPrint('Pause error: $e');
  }
}



  // =================================================
  // UI
  // =================================================
  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xffF3F4F6),
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: const Text(
        'Trip Schedule',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
   body: isLoading || destination == null || currentLocation == null
    ? const Center(child: CircularProgressIndicator())
    : Stack(

            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentLocation ?? LatLng(0, 0),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.journeys',
                  ),
                  MarkerLayer(
                    markers: [
                      if (currentLocation != null)
                        Marker(
                          point: currentLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.navigation,
                            color: primaryBlue,
                            size: 30,
                          ),
                        ),
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
                  PolylineLayer(
                    polylines: (currentLocation != null && destination != null)
                        ? <Polyline>[
                            Polyline(
                              points: [currentLocation!, destination!],
                              strokeWidth: 4.0,
                              color: Colors.blueAccent,
                            ),
                          ]
                        : <Polyline>[],
                  ),
                  const CurrentLocationLayer(),
                ],
              ),
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
    final nextSteps = routeSteps.skip(currentStepIndex + 1).toList();

    final distance = Distance();
    final double km = (destination == null || currentLocation == null)
    ? 0
    : distance.as(
        LengthUnit.Kilometer,
        currentLocation!,
        destination!,
      );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Current Location - ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const TextSpan(
                  text: 'Denpasar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Going to, Bedugul - ',
                  style: TextStyle(color: softGrey),
                ),
                TextSpan(
                  text: currentStep['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "est - ${km.toStringAsFixed(1)} km left",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isArrived ? null : onArrived,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Arrived!",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isPaused ? 'Resume' : 'Pause',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
         const SizedBox(height: 20),
const Text(
  'Next Location',
  style: TextStyle(fontWeight: FontWeight.w600),
),
const SizedBox(height: 10),
if (nextSteps.isNotEmpty)
  ...nextSteps.map(
    (step) => buildNextLocationCard(
      step['title'],
      (step['tags'] as List).isNotEmpty ? step['tags'][0] : '',
      "Bedugul",
    ),
  )
else
  buildNextLocationCard(
    currentStep['title'], // ✅ Gunakan currentStep (karena step tidak ada di luar map)
    '',
    "Bedugul",
    address: "Jalan Campuhan, Ubud, Bali, 80571, IDN", // atau currentStep['address'] jika ada
    subtitle: "fsdfsd", // atau currentStep['description'] jika tersedia
  ),


        ],
      ),
    );
  }

  Widget buildNextLocationCard(String title, String tag, String location, {String? address = '', String? subtitle = ''}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            'https://picsum.photos/80', // Atau gunakan image dari API jika ada
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lokasi 1 : $title",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                address ?? "",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle ?? "",
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.bookmark_border),
        ),
      ],
    ),
  );
}

}
