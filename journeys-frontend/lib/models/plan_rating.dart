import 'route_model.dart';

class PlanModelRating {
  final int planId;
  final String title;
  final String description;
  final String bannerBase64;
  final List<dynamic> categories;
  final String status;
  final String authorName;
  final double rating;
  final List<RouteModel> routes;

  PlanModelRating({
    required this.planId,
    required this.title,
    required this.description,
    required this.bannerBase64,
    required this.categories,
    required this.status,
    required this.authorName,
    required this.rating,
    required this.routes,
  });

 factory PlanModelRating.fromJson(Map<String, dynamic> json) {
  final routesList = json['routes'] as List<dynamic>? ?? [];

  return PlanModelRating(
    planId: json['plan_id'] ?? 0,
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    bannerBase64: json['banner'] ?? '',
    categories: json['categories'] ?? [],
    status: json['status'] ?? '',
    authorName: json['author_name'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    routes: routesList
        .map((r) => RouteModel.fromJson(r))
        .toList(),
  );
}


}
