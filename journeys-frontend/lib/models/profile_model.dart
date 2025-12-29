class ProfileModel {
  final int profileId;
  final int userId;
  final String? name; // I'm adding name here as it's on the screen
  final String? photo;
  final String? location;
  final String? birthDate;
  final String? description;
  final String? languages;
  final String? status;
  final String rank;
  final int followers;
  final int following;

  ProfileModel({
    required this.profileId,
    required this.userId,
    this.name,
    this.photo,
    this.location,
    this.birthDate,
    this.description,
    this.languages,
    this.status,
    required this.rank,
    required this.followers,
    required this.following,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      profileId: json['profile_id'],
      userId: json['user_id'],
      name: json['name'], // Assuming name comes from the API
      photo: json['photo'],
      location: json['location'],
      birthDate: json['birth_date'],
      description: json['description'],
      languages: json['languages'],
      status: json['status'],
      rank: json['rank'],
      followers: json['followers'],
      following: json['following'],
    );
  }
}
