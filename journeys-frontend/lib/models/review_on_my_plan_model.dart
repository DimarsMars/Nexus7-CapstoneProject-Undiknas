import 'simple_user_model.dart';

class ReviewOnMyPlanModel {
  final int reviewId;
  final String comment;
  final double rating;
  final SimpleUserModel user;

  ReviewOnMyPlanModel({
    required this.reviewId,
    required this.comment,
    required this.rating,
    required this.user,
  });

  factory ReviewOnMyPlanModel.fromJson(Map<String, dynamic> json) {
    return ReviewOnMyPlanModel(
      reviewId: json['review_id'] ?? 0,
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      user: SimpleUserModel.fromJson(json['user'] ?? {}),
    );
  }
}
