import '../repositories/client_repository.dart';

class CreateClientAndBookAppointment {
  final ClientRepository repository;

  CreateClientAndBookAppointment(this.repository);

  Future<Map<String, dynamic>> call({
    required String fullName,
    required String email,
    required String phone,
    required Map<String, dynamic> appointmentData,
    String? gender,
    DateTime? dateOfBirth,
    String? preferredLanguage,
    String? statusReason,
    String? classId,
    String? rescheduledFrom,
    bool? isCancelled,
    String? preferredContactMethod,
    bool? marketingConsent,
    String? clientNotes,
  }) async {
    return await repository.createClientAccountAndBookAppointment(
      fullName: fullName,
      email: email,
      phone: phone,
      appointmentData: appointmentData,
      gender: gender,
      dateOfBirth: dateOfBirth,
      preferredLanguage: preferredLanguage,
      statusReason: statusReason,
      classId: classId,
      rescheduledFrom: rescheduledFrom,
      isCancelled: isCancelled,
      preferredContactMethod: preferredContactMethod,
      marketingConsent: marketingConsent,
      clientNotes: clientNotes,
    );
  }
}