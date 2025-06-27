// lib/core/models/user_model.dart
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String preferredLanguage;
  final bool isVerified;
  final bool isActive;
  final List<String> businessIds;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.preferredLanguage,
    required this.isVerified,
    required this.isActive,
    required this.businessIds,
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
    );
  }
}
