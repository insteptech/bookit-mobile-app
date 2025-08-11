class Appointment {
  final String id;
  final String businessId;
  final String locationId;
  final String businessServiceId;
  final String practitionerId;
  final String practitionerName;
  final String serviceName;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? clientId;
  final String? clientName;

  const Appointment({
    required this.id,
    required this.businessId,
    required this.locationId,
    required this.businessServiceId,
    required this.practitionerId,
    required this.practitionerName,
    required this.serviceName,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.clientId,
    this.clientName,
  });

  Appointment copyWith({
    String? id,
    String? businessId,
    String? locationId,
    String? businessServiceId,
    String? practitionerId,
    String? practitionerName,
    String? serviceName,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? clientId,
    String? clientName,
  }) {
    return Appointment(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      locationId: locationId ?? this.locationId,
      businessServiceId: businessServiceId ?? this.businessServiceId,
      practitionerId: practitionerId ?? this.practitionerId,
      practitionerName: practitionerName ?? this.practitionerName,
      serviceName: serviceName ?? this.serviceName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
    );
  }
}
