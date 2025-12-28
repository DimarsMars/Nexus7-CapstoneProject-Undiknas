class PlanModel {
  final int planId;
  final String title;
  final String description;
  final String bannerBase64;
  final List<dynamic> categories;
  final String status;
  final double rating; // ✅ Tambahkan ini
  final String authorName;


  PlanModel({
    required this.planId,
    required this.title,
    required this.description,
    required this.bannerBase64,
    required this.categories,
    required this.status,
    required this.authorName,
    required this.rating, // ✅ Tambahkan ini
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      planId: json['plan_id'],
      title: json['title'],
      description: json['description'],
      bannerBase64: json['banner'] ?? '',
      categories: json['categories'] ?? [],
      status: json['status'] ?? '',
      authorName: json['author_name'] ?? '', // ✅ Parsing author name
      rating: (json['rating'] ?? 0).toDouble(), // ✅ Parsing rating
    );
  }
}
