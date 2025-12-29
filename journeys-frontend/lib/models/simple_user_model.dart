class SimpleUserModel {
  final int userId;
  final String username;
  final String photo;
  final String rank;

  SimpleUserModel({
    required this.userId,
    required this.username,
    required this.photo,
    required this.rank,
  });

  factory SimpleUserModel.fromJson(Map<String, dynamic> json) {
    return SimpleUserModel(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      photo: json['photo'] ?? '',
      rank: json['rank'] ?? '',
    );
  }
}
