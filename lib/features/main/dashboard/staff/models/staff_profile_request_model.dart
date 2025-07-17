//data model for staff profile
import 'dart:io';

class StaffProfile {
  String? id;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final String categoryId;
  final List<String> locationIds;
  final File? profileImage;
  final bool isAvailable;
  final String userId; 
  String? profilePhotoUrl;

  StaffProfile({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.categoryId,
    required this.locationIds,
    this.profileImage,
    this.isAvailable = true,
    this.profilePhotoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'category_id': categoryId,
      'location_id': locationIds,
      'is_available': isAvailable,
    };
  }
}