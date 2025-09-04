import '../entities/practitioner.dart';
import '../repositories/appointment_repository.dart';

class GetPractitioners {
  final AppointmentRepository repository;

  const GetPractitioners(this.repository);

  Future<List<Practitioner>> call(String locationId) {
    return repository.getPractitioners(locationId);
  }
}
