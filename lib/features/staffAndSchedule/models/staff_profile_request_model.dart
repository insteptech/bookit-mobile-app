//data model for staff profile
import 'dart:io';

class StaffProfile {
  String? id;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final List<String> categoryIds;
  final List<String>? locationIds;
  final File? profileImage;
  final bool? isAvailable;
  final bool? forClass;
  String? profilePhotoUrl;

  StaffProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.categoryIds,
    this.locationIds,
    this.profileImage,
    this.isAvailable,
    this.forClass,
    this.profilePhotoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'category_id': categoryIds,
      'location_id': locationIds,
      'is_available': isAvailable,
      'for_class': forClass,
    };
  }
}