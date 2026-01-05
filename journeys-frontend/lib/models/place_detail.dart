class PlaceDetail {
  final int routeId;
  final String title;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String imageBase64;

  PlaceDetail({
    required this.routeId,
    required this.title,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageBase64,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      routeId: json['route_id'],
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      address: json['address'] ?? "",
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      imageBase64: json['image'] ?? "",
    );
  }
}
