import 'package:flutter/material.dart';

class Appointment {
  final TimeOfDay startTime;
  final int durationMinutes;
  final String serviceName;
  final String clientName;
 
  Appointment({
    required this.startTime,
    required this.durationMinutes,
    required this.serviceName,
    required this.clientName,
  });
 
  factory Appointment.fromJson(Map<String, dynamic> json) {
    final parts = json['start_time'].split(':');
    return Appointment(
      startTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      durationMinutes: json['duration_minutes'],
      serviceName: json['service_name'],
      clientName: json['client_name'],
    );
  }
}
 
class StaffAppointments {
  final String staffId;
  final String staffName;
  final List<Appointment> appointments;
 
  StaffAppointments({
    required this.staffId,
    required this.staffName,
    required this.appointments,
  });
 
  factory StaffAppointments.fromJson(Map<String, dynamic> json) {
    return StaffAppointments(
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      appointments: (json['appointments'] as List)
          .map((e) => Appointment.fromJson(e))
          .toList(),
    );
  }
}