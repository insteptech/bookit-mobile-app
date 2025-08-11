import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:dio/dio.dart';

class AppointmentApiService {
  
  Future<Map<String, dynamic>> getPractitioners(String locationId) async {
    return await APIRepository.getPractitioners(locationId);
  }

  Future<Map<String, dynamic>> getServiceList() async {
    return await APIRepository.getServiceList();
  }

  Future<Response> bookAppointment({
    required List<Map<String, dynamic>> payload,
  }) async {
    return await APIRepository.bookAppointment(payload: payload);
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String practitionerId,
    required String businessServiceId,
    required String selectedDate,
  }) async {
    // TODO: Implement when the actual API method is available
    // This is a placeholder for the schedule API call
    return [];
  }
}
