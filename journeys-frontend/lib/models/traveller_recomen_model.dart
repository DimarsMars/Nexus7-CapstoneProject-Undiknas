class TravellerRecommendationModel {
  final int categoryId;
  final String category;
  final String imageBase64;
  final UserRecoModel user;

  TravellerRecommendationModel({
    required this.categoryId,
    required this.category,
    required this.imageBase64,
    required this.user,
  });

  factory TravellerRecommendationModel.fromJson(Map<String, dynamic> json) {
    return TravellerRecommendationModel(
      categoryId: json['category_id'],
      category: json['category'],
      imageBase64: json['image'] ?? '',
      user: UserRecoModel.fromJson(json['user'] ?? {}),
    );
  }
}

class UserRecoModel {
  final int userId;
  final String username;
  final String role;
  final String rank;
  final String photoBase64;

  UserRecoModel({
    required this.userId,
    required this.username,
    required this.role,
    required this.rank,
    required this.photoBase64,
  });

  factory UserRecoModel.fromJson(Map<String, dynamic> json) {
    return UserRecoModel(
      userId: json['user_id'],
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      rank: json['rank'] ?? '',
      photoBase64: json['photo'] ?? '',
    );
  }
}
