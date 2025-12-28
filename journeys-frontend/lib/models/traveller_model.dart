class TravellerModel {
  final int userId;
  final String username;
  final String rank;
  final String role;
  final String photoBase64;

  TravellerModel({
    required this.userId,
    required this.username,
    required this.rank,
    required this.role,
    required this.photoBase64,
  });

  factory TravellerModel.fromJson(Map<String, dynamic> json) {
    return TravellerModel(
      userId: json['user_id'],
      username: json['username'] ?? '',
      rank: json['rank'] ?? '',
      role: json['role'] ?? '',
      photoBase64: json['photo'] ?? '',
    );
  }
}
