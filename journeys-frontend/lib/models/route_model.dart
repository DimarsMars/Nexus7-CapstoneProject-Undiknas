class RouteModel {
  final int routeId;
  final String title;
  final String address;
  final String description;
  final String imageBase64;
  final double latitude;
  final double longitude;
  final int stepOrder;
  final List<dynamic> tags;

  RouteModel({
    required this.routeId,
    required this.title,
    required this.address,
    required this.description,
    required this.imageBase64,
    required this.latitude,
    required this.longitude,
    required this.stepOrder,
    required this.tags,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['route_id'],
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      imageBase64: json['image'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      stepOrder: json['step_order'] ?? 0,
      tags: json['tags'] ?? [],
    );
  }
}
