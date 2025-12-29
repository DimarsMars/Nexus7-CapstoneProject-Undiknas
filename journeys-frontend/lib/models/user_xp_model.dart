class UserXpModel {
  final String rank;
  final int xp;
  final int nextLevelXp;
  final int level;

  UserXpModel({
    required this.rank,
    required this.xp,
    required this.nextLevelXp,
    required this.level,
  });

  factory UserXpModel.fromJson(Map<String, dynamic> json) {
    return UserXpModel(
      rank: json['rank'] ?? '',
      xp: json['xp'] ?? 0,
      nextLevelXp: json['next_level_xp'] ?? 100,
      level: json['level'] ?? 1,
    );
  }

  double get progressPercentage {
    if (nextLevelXp <= 0) return 0.0;
    return xp / nextLevelXp;
  }
}
