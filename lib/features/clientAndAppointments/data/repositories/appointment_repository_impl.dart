import '../../domain/entities/practitioner.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  const AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Practitioner>> getPractitioners(String locationId) async {
    try {
      final models = await remoteDataSource.getPractitioners(locationId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get practitioners - ${e.toString()}');
    }
  }

  @override
  Future<List<Service>> getServices() async {
    try {
      final models = await remoteDataSource.getServices();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get services - ${e.toString()}');
    }
  }

  @override
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
  }) async {
    final payload = [{
      'business_id': businessId,
      'location_id': locationId,
      'business_service_id': businessServiceId,
      'status': 'booked',
      'practitioner': practitionerId,
      'date': date.toIso8601String(),
      'start_from': startTime,
      'end_at': endTime,
      'user_id': userId,
      'status_reason': "",
      if (clientId != null) 'booked_by': clientId,  // Changed from 'client_id' to 'booked_by'
    }];

    await remoteDataSource.bookAppointment(payload: payload);
  }
}
