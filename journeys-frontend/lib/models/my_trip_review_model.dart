import 'simple_plan_model.dart';

class MyTripReviewModel {
  final int reviewId;
  final String comment;
  final double rating;
  final SimplePlanModel plan;

  MyTripReviewModel({
    required this.reviewId,
    required this.comment,
    required this.rating,
    required this.plan,
  });

  factory MyTripReviewModel.fromJson(Map<String, dynamic> json) {
    return MyTripReviewModel(
      reviewId: json['review_id'] ?? 0,
      comment: json['comment'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      plan: SimplePlanModel.fromJson(json['plan'] ?? {}),
    );
  }
}
