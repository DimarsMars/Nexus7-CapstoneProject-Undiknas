class PlaceReview {
  final int reviewId;
  final int userId;
  final int routeId;
  final int rating;
  final String comment;
  final List<String> imageBase64List; // <- gunakan ini
  final DateTime createdAt;

  PlaceReview({
    required this.reviewId,
    required this.userId,
    required this.routeId,
    required this.rating,
    required this.comment,
    required this.imageBase64List,
    required this.createdAt,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    final image = (json['image'] as List<dynamic>?)
        ?.map((img) => img.toString())
        .toList() ?? [];

    return PlaceReview(
      reviewId: json['review_id'],
      userId: json['user_id'],
      routeId: json['route_id'],
      rating: json['rating'],
      comment: json['comment'],
      imageBase64List: image,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
