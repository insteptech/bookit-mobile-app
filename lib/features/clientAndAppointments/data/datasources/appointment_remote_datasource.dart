import '../../../../core/services/remote_services/network/api_provider.dart';
import '../models/practitioner_model.dart';
import '../models/service_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<PractitionerModel>> getPractitioners(String locationId);
  Future<List<ServiceModel>> getServices();
  Future<void> bookAppointment({required List<Map<String, dynamic>> payload});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  @override
  Future<List<PractitionerModel>> getPractitioners(String locationId) async {
    try {
      final response = await APIRepository.getPractitioners(locationId);
      
      // Debug logging - remove in production
      // print('\n=== COMPLETE PRACTITIONER BACKEND DATA ===');
      // print('API Response: $response');
      // print('=== END PRACTITIONER DATA ===\n');
      
      // The API returns data under 'profiles' key, not 'data'
      final List<dynamic> practitionersData = response['profiles'] ?? response['data'] ?? [];
      
      return practitionersData
          .map((json) => PractitionerModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to fetch practitioners: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await APIRepository.getServiceList();
      
      // The API returns data under 'business_services_details' key, not 'data'
      final List<dynamic> servicesData = response['business_services_details'] ?? response['data'] ?? [];
      
      // Transform the data to match our expected format
      final List<ServiceModel> services = [];
      for (int index = 0; index < servicesData.length; index++) {
        final item = servicesData[index];
        services.add(ServiceModel.fromJson({
          "name": item['name'],
          "description": item['description'],
          "id": "${item['business_service']['id']}_$index",
          "business_service_id": item['business_service']['id'],
          "is_class": item['business_service']['is_class'],
          "durations": item['durations'],
        }));
      }
      
      // Filter only non-class services
      final filteredServices = services.where((service) => !service.isClass).toList();
      return filteredServices;
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to fetch services: ${e.toString()}');
    }
  }

  @override
  Future<void> bookAppointment({required List<Map<String, dynamic>> payload}) async {
    await APIRepository.bookAppointment(payload: payload);
  }
}
