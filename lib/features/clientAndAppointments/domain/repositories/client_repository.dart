import '../entities/client.dart';

abstract class ClientRepository {
  Future<List<Client>> getClients({String? searchQuery});
  Future<Client> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  });
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String clientId);
}
