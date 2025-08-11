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
      // Determine search type based on query format
      String? fullName;
      String? email;
      String? phoneNumber;
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.trim();
        
        // Check if it looks like an email
        if (query.contains('@')) {
          email = query;
        }
        // Check if it looks like a phone number (contains only digits, spaces, +, -, (, ))
        else if (RegExp(r'^[\d\s\+\-\(\)]+$').hasMatch(query)) {
          phoneNumber = query;
        }
        // Otherwise treat as name search
        else {
          fullName = query;
        }
      }
      
      final response = await APIRepository.fetchClients(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      
      // Handle the actual API response structure
      List<dynamic> clientsData = [];
      if (response['data'] != null && response['data']['profile'] != null) {
        clientsData = response['data']['profile'];
      } else if (response['data'] != null) {
        clientsData = response['data'];
      } else if (response['profile'] != null) {
        clientsData = response['profile'];
      }
      
      // Transform the API response to match our ClientModel expectations
      final transformedClients = clientsData.map((json) {
        // Split full_name into first and last name
        final fullName = json['full_name']?.toString() ?? '';
        final nameParts = fullName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        return {
          'id': json['id'],
          'first_name': firstName,
          'last_name': lastName,
          'email': json['email'],
          'phone_number': json['phone'], // Map 'phone' to 'phone_number'
          'date_of_birth': null,
          'address': null,
          'notes': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList();
      
      return transformedClients.map((json) => ClientModel.fromJson(json)).toList();
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
