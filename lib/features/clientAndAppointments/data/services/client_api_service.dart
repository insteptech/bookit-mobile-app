import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';

class ClientApiService {
  
  Future<Map<String, dynamic>> fetchClients({String? fullName}) async {
    return await APIRepository.fetchClients(fullName: fullName);
  }

  Future<Map<String, dynamic>> createClient({
    required String name,
    required String email,
    required String phone,
  }) async {
    // TODO: Implement client creation API when backend route is available
    // This is a placeholder for the client creation API call
    throw UnimplementedError('Client creation API not yet implemented on backend');
  }
}
