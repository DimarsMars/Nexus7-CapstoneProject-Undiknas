import 'package:journeys/models/plan_model.dart';
import 'package:journeys/models/route_model.dart';

class PlanDetailModel {
  final String bannerBase64;
  final PlanModel plan;
  final List<RouteModel> routes;

  PlanDetailModel({
    required this.bannerBase64,
    required this.plan,
    required this.routes,
  });

  factory PlanDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanDetailModel(
      bannerBase64: json['banner'] ?? '',
      plan: PlanModel.fromJson(json['plan']),
      routes: (json['routes'] as List<dynamic>?)
              ?.map((e) => RouteModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
