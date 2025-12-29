class TravellerProfileModel {
  final int userId;
  final String username;
  final String email;
  final String role;
  final String photoBase64;
  final String rank;
  final int followers;
  final int following;
  final int reviews;
  final int routes;
  final List<dynamic> plans;

  TravellerProfileModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.photoBase64,
    required this.rank,
    required this.followers,
    required this.following,
    required this.reviews,
    required this.routes,
    required this.plans,
  });

  factory TravellerProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return TravellerProfileModel(
      userId: json['user_id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      photoBase64: json['photo'] ?? '',
      rank: json['rank'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      reviews: stats['reviews'] ?? 0,
      routes: stats['routes'] ?? 0,
      plans: json['plans'] ?? [],
    );
  }
}
