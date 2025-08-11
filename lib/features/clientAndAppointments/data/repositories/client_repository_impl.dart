import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;

  const ClientRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Client>> getClients({String? searchQuery}) async {
    final models = await remoteDataSource.getClients(searchQuery: searchQuery);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Client> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  }) async {
    final model = await remoteDataSource.createClient(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      address: address,
      notes: notes,
    );
    return model.toEntity();
  }

  @override
  Future<Client> updateClient(Client client) {
    // TODO: Implement when API is available
    throw UnimplementedError();
  }

  @override
  Future<void> deleteClient(String clientId) {
    // TODO: Implement when API is available
    throw UnimplementedError();
  }
}
