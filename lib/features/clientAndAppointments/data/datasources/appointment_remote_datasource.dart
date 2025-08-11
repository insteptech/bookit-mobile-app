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
      print('Fetching practitioners for location: $locationId');
      final response = await APIRepository.getPractitioners(locationId);
      print('Practitioners API response: $response');
      
      // The API returns data under 'profiles' key, not 'data'
      final List<dynamic> practitionersData = response['profiles'] ?? response['data'] ?? [];
      print('Practitioners data length: ${practitionersData.length}');
      
      return practitionersData
          .map((json) => PractitionerModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching practitioners: $e');
      if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to fetch practitioners: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      print('Fetching services...');
      final response = await APIRepository.getServiceList();
      print('Services API response keys: ${response.keys}');
      
      // The API returns data under 'business_services_details' key, not 'data'
      final List<dynamic> servicesData = response['business_services_details'] ?? response['data'] ?? [];
      print('Services data length: ${servicesData.length}');
      
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
      print('Filtered services count: ${filteredServices.length}');
      return filteredServices;
    } catch (e) {
      print('Error fetching services: $e');
      if (e.toString().contains('401')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to fetch services: ${e.toString()}');
    }
  }

  @override
  Future<void> bookAppointment({required List<Map<String, dynamic>> payload}) async {
    try {
      print('Booking appointment with payload: $payload');
      await APIRepository.bookAppointment(payload: payload);
      print('Appointment booked successfully');
    } catch (e) {
      print('Error booking appointment: $e');
      rethrow;
    }
  }
}
