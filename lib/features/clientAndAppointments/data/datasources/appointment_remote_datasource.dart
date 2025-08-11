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
      final List<dynamic> practitionersData = response['data'] ?? [];
      return practitionersData
          .map((json) => PractitionerModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch practitioners: ${e.toString()}');
    }
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await APIRepository.getServiceList();
      final List<dynamic> servicesData = response['data'] ?? [];
      
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
      return services.where((service) => !service.isClass).toList();
    } catch (e) {
      throw Exception('Failed to fetch services: ${e.toString()}');
    }
  }

  @override
  Future<void> bookAppointment({required List<Map<String, dynamic>> payload}) async {
    await APIRepository.bookAppointment(payload: payload);
  }
}
