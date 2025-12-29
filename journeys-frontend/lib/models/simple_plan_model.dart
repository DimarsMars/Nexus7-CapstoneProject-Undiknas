class SimplePlanModel {
  final int planId;
  final String title;
  final String description;
  final String banner;

  SimplePlanModel({
    required this.planId,
    required this.title,
    required this.description,
    required this.banner,
  });

  factory SimplePlanModel.fromJson(Map<String, dynamic> json) {
    return SimplePlanModel(
      planId: json['plan_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      banner: json['banner'] ?? '',
    );
  }
}
