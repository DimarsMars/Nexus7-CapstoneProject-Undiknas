class ActiveTripSessionModel {
  final int sessionId;
  final PlanForSession plan;

  ActiveTripSessionModel({
    required this.sessionId,
    required this.plan,
  });

  factory ActiveTripSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveTripSessionModel(
      sessionId: json['session_id'],
      plan: PlanForSession.fromJson(json['Plan'] ?? {}),
    );
  }
}

class PlanForSession {
  final int planId;
  final String title;
  final String description;
  final String bannerBase64;
  final List<RouteForSession> routes;

  PlanForSession({
    required this.planId,
    required this.title,
    required this.description,
    required this.bannerBase64,
    required this.routes,
  });

  factory PlanForSession.fromJson(Map<String, dynamic> json) {
    return PlanForSession(
      planId: json['plan_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bannerBase64: json['banner'] ?? '',
      routes: (json['routes'] as List<dynamic>?)
              ?.map((e) => RouteForSession.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RouteForSession {
  final String address;

  RouteForSession({required this.address});

  factory RouteForSession.fromJson(Map<String, dynamic> json) {
    return RouteForSession(
      address: json['address'] ?? '',
    );
  }
}
