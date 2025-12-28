class MostActiveTravellerModel {
  final int userId;
  final String username;
  final String role;
  final int xp;
  final String photoBase64;

  MostActiveTravellerModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.xp,
    required this.photoBase64,
  });

  factory MostActiveTravellerModel.fromJson(Map<String, dynamic> json) {
    return MostActiveTravellerModel(
      userId: json['user_id'],
      username: json['username'],
      role: json['role'] ?? '',
      xp: json['xp'] ?? 0,
      photoBase64: json['photo'] ?? '',
    );
  }
}
