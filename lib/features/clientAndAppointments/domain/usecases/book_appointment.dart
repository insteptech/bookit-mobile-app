import '../repositories/appointment_repository.dart';

class BookAppointment {
  final AppointmentRepository repository;

  const BookAppointment(this.repository);

  Future<void> call({
    required String businessId,
    required String locationId,
    required String businessServiceId,
    required String practitionerId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String userId,
    required int durationMinutes,
    required String serviceName,
    required String practitionerName,
    String? clientId,
  }) {
    return repository.bookAppointment(
      businessId: businessId,
      locationId: locationId,
      businessServiceId: businessServiceId,
      practitionerId: practitionerId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      userId: userId,
      durationMinutes: durationMinutes,
      serviceName: serviceName,
      practitionerName: practitionerName,
      clientId: clientId,
    );
  }
}
