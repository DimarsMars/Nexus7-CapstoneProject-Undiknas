class UserModel {
  final int userId;
  final String username;
  final String email;
  final String firebaseUid;
  final String role;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.firebaseUid,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      role: json['role'],
    );
  }
}
