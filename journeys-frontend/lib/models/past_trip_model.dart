import 'package:journeys/models/route_model.dart';

class PastTripModel {
  final int progressId;
  final int planId;
  final String title;
  final String description;
  final String? banner;
  final List<RouteModel> routes;

  PastTripModel({
    required this.progressId,
    required this.planId,
    required this.title,
    required this.description,
    this.banner,
    required this.routes,
  });

  factory PastTripModel.fromJson(Map<String, dynamic> json) {
    var routesList = json['routes'] as List? ?? [];
    List<RouteModel> routes = routesList.map((i) => RouteModel.fromJson(i)).toList();

    return PastTripModel(
      progressId: json['progress_id'] ?? 0,
      planId: json['plan_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      banner: json['banner'],
      routes: routes,
    );
  }
}
