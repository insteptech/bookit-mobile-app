import '../entities/service.dart';
import '../repositories/appointment_repository.dart';

class GetServices {
  final AppointmentRepository repository;

  const GetServices(this.repository);

  Future<List<Service>> call() {
    return repository.getServices();
  }
}
