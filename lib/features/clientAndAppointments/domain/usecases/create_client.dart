import '../entities/client.dart';
import '../repositories/client_repository.dart';

class CreateClient {
  final ClientRepository repository;

  const CreateClient(this.repository);

  Future<Client> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  }) {
    return repository.createClient(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      address: address,
      notes: notes,
    );
  }
}
