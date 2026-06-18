class ProfileModel {
  final int userId;
  final String academicLevel;
  final List<String> interests;
  final String? avatarUrl;

  ProfileModel({
    required this.userId,
    required this.academicLevel,
    required this.interests,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] ?? 0,
      academicLevel: json['academic_level'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'academic_level': academicLevel,
      'interests': interests,
      'avatar_url': avatarUrl,
    };
  }
}