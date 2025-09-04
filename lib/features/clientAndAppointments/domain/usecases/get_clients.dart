import '../entities/client.dart';
import '../repositories/client_repository.dart';

class GetClients {
  final ClientRepository repository;

  const GetClients(this.repository);

  Future<List<Client>> call({String? searchQuery}) {
    return repository.getClients(searchQuery: searchQuery);
  }
}
