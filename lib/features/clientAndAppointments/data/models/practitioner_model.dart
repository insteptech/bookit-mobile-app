import '../../domain/entities/practitioner.dart';

class PractitionerModel extends Practitioner {
  const PractitionerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.locationSchedules,
    required super.serviceIds,
  });

  factory PractitionerModel.fromJson(Map<String, dynamic> json) {
    return PractitionerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      locationSchedules: List<Map<String, dynamic>>.from(
        json['location_schedules'] ?? [],
      ),
      serviceIds: List<String>.from(
        (json['service_ids'] ?? []).map((id) => id.toString()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'location_schedules': locationSchedules,
      'service_ids': serviceIds,
    };
  }

  Practitioner toEntity() => this;
}
