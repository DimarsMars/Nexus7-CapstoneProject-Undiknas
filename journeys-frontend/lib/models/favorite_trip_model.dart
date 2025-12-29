import 'package:journeys/models/plan_model.dart';

class FavoriteTripModel {
  final int favoriteId;
  final PlanModel plan;

  FavoriteTripModel({
    required this.favoriteId,
    required this.plan,
  });

  factory FavoriteTripModel.fromJson(Map<String, dynamic> json) {
    return FavoriteTripModel(
      favoriteId: json['favorite_id'] ?? 0,
      plan: PlanModel.fromJson(json['plan'] ?? {}),
    );
  }
}
