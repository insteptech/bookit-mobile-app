class Practitioner {
  final String id;
  final String name;
  final String email;
  final List<Map<String, dynamic>> locationSchedules;
  final List<String> serviceIds;

  const Practitioner({
    required this.id,
    required this.name,
    required this.email,
    required this.locationSchedules,
    required this.serviceIds,
  });

  Practitioner copyWith({
    String? id,
    String? name,
    String? email,
    List<Map<String, dynamic>>? locationSchedules,
    List<String>? serviceIds,
  }) {
    return Practitioner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      locationSchedules: locationSchedules ?? this.locationSchedules,
      serviceIds: serviceIds ?? this.serviceIds,
    );
  }
}
