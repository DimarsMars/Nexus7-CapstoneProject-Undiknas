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
  bool isLoading = true;

  LatLng? currentLocation;
  LatLng? destination;

  List<Map<String, dynamic>> routeSteps = [];
  int currentStepIndex = 0;

  late StreamSubscription<Position> positionStream;

  // ================= INIT =================
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

  // ================= LOCATION =================
  Future<void> _initCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    currentLocation = LatLng(position.latitude, position.longitude);
    mapController.move(currentLocation!, 12);
  }

  void _startLocationUpdates() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  // ================= TRIP SESSION =================
  Future<void> _loadTripSession() async {
    try {
      final sessions = await ApiService().getActiveTripSessions();
      final session = sessions.firstWhere(
        (s) => s['plan_id'] == widget.planId,
        orElse: () => {},
      );

      if (session.isEmpty) {
        context.pop();
        return;
      }

      final planDetail =
          await ApiService().getPlanDetailForTrip(widget.planId);
      final steps = planDetail?.routes ?? [];

      final index =
          steps.indexWhere((s) => s.routeId == session['route_id']);

      setState(() {
        routeSteps = steps
            .map((e) => {
                  'route_id': e.routeId,
                  'step_order': e.stepOrder,
                  'title': e.title,
                  'latitude': e.latitude,
                  'longitude': e.longitude,
                  'tags': e.tags,
                })
            .toList();

        currentStepIndex = index;
        destination = LatLng(
          routeSteps[index]['latitude'],
          routeSteps[index]['longitude'],
        );
        isPaused = session['status'] == 'paused';
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      context.pop();
    }
  }

  // ================= ACTIONS =================
  Future<void> onArrived() async {
    if (currentLocation == null) return;

    final step = routeSteps[currentStepIndex];
    final response = await ApiService().verifyLocation(
      widget.planId,
      step['step_order'],
      currentLocation!,
    );

    if (!mounted || response == null) return;

    if (response['next_route'] != null) {
      final next = response['next_route'];

      await ApiService().postTripSessionAction(
        planId: widget.planId,
        action: 'start',
        routeId: next['route_id'],
      );

      setState(() {
        currentStepIndex++;
        destination = LatLng(next['latitude'], next['longitude']);
        isPaused = false;
      });
    } else {
      context.go('/home');
    }
  }

  Future<void> onPause() async {
    final step = routeSteps[currentStepIndex];
    final action = isPaused ? 'resume' : 'pause';

    final success = await ApiService().postTripSessionAction(
      planId: widget.planId,
      action: action,
      routeId: step['route_id'],
    );

    if (success && mounted) {
      setState(() => isPaused = !isPaused);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading || currentLocation == null || destination == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Schedule')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.journeys',
              ),
              const CurrentLocationLayer(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onArrived,
              style:
                  ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text('Arrived'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onPause,
              style:
                  ElevatedButton.styleFrom(backgroundColor: darkBlue),
              child: Text(isPaused ? 'Resume' : 'Pause'),
            ),
          ),
        ],
      ),
    );
  }
}
