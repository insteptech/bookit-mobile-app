import '../../../../core/services/remote_services/network/api_provider.dart';
import '../models/client_model.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients({String? searchQuery});
  Future<ClientModel> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  });
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  @override
  Future<List<ClientModel>> getClients({String? searchQuery}) async {
    try {
      final response = await APIRepository.fetchClients(
        fullName: searchQuery,
        email: searchQuery,
        phoneNumber: searchQuery,
      );
      
      // Handle both 'data' and 'profile' response formats safely
      List<dynamic> clientsData = [];
      if (response['data'] != null) {
        clientsData = response['data'];
      } else if (response['profile'] != null) {
        clientsData = response['profile'];
      }
      
      return clientsData.map((json) => ClientModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch clients: ${e.toString()}');
    }
  }

  @override
  Future<ClientModel> createClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? notes,
  }) async {
    try {
      final response = await APIRepository.createClientAccount(
        payload: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
          if (address != null) 'address': address,
          if (notes != null) 'notes': notes,
        },
      );
      return ClientModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create client: ${e.toString()}');
    }
  }
}
