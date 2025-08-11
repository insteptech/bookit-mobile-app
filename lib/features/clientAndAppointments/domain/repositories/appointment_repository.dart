import '../entities/practitioner.dart';
import '../entities/service.dart';

abstract class AppointmentRepository {
  Future<List<Practitioner>> getPractitioners(String locationId);
  Future<List<Service>> getServices();
  Future<void> bookAppointment({
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
  });
}
