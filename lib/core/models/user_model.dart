class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String preferredLanguage;
  final bool isVerified;
  final bool isActive;
  final List<String> businessIds;
  final String? provider;
  final String? socialId;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.preferredLanguage,
    required this.isVerified,
    required this.isActive,
    required this.businessIds,
    this.provider,
    this.socialId,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      preferredLanguage: json['preferred_language'],
      isVerified: json['is_verified'],
      isActive: json['is_active'],
      businessIds: List<String>.from(json['business_ids']),
      provider: json['provider'],
      socialId: json['social_id'],
      avatarUrl: json['avatar_url'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'preferred_language': preferredLanguage,
      'is_verified': isVerified,
      'is_active': isActive,
      'business_ids': businessIds,
      'provider': provider,
      'social_id': socialId,
      'avatar_url': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
