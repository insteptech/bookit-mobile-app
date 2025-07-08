import 'dart:convert';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_interceptor.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/endpoint.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/features/main/home/staff/models/staff_profile_request_model.dart';
import 'package:dio/dio.dart';


// APIRepository handles all API calls related to staff management, including adding multiple staff members, fetching staff lists, and managing staff schedules.

class APIRepository {
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl))
    ..interceptors.add(AuthInterceptor(
      dio: Dio(BaseOptions(baseUrl: baseUrl)), // for refresh call
      tokenService: TokenService(),
    ));


  //.................................Add Multiple Staff.............................
  /// Adds multiple staff profiles to the system.
  static Future<Response> addMultipleStaff({
    required List<StaffProfile> staffProfiles,
  }) async {
    // Get user ID
    String userId = "";
    final userDetails = await AuthStorageService().getUserDetails();
    if (userDetails != null) {
      Map<String, dynamic> jsonData = jsonDecode(userDetails);
      userId = jsonData['id'];
    } else {
      return Response(
        requestOptions: RequestOptions(path: addStaffEndpoint),
        statusCode: 400,
        data: {'error': 'User not logged in'},
      );
    }

    // Build list of profiles
    final List<Map<String, dynamic>> profilesData =
        staffProfiles.map((profile) {
          final profileJson = profile.toJson();
          profileJson['user_id'] = userId;

          // Ensure correct structure
          profileJson['is_available'] = profileJson['is_available'] == true;
          if (profileJson['location_id'] is! List) {
            profileJson['location_id'] = [profileJson['location_id']];
          }

          return profileJson;
        }).toList();

    // Send request
    final response = await _dio.post(
      addStaffEndpoint,
      data: {'staffProfiles': jsonEncode(profilesData)},
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Manually check response
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response; 
    } else {
      return Response(
        requestOptions: RequestOptions(path: addStaffEndpoint),
        statusCode: response.statusCode,
        data: {
          'error': 'Failed to add staff members',
          'details': response.data,
        },
      );
    }
  }

  //..........................Fetch User Data for Staff Registration..................

  static Future<Response> getUserDataForStaffRegistration() async {
    try {
      final userDetails = await AuthStorageService().getUserDetails();
      String userId = "";

      if (userDetails != null) {
        Map<String, dynamic> jsonData = jsonDecode(userDetails);
        userId = jsonData['id'];
      } else {
        // print("No user details found.");
      }
      final String fetchUrl =
          "$getUserRegisteredCategoriesEndpoint/$userId/summary";
      final response = await _dio.get(fetchUrl);
      // print(response.data);
      return response;
    } catch (e) {
      throw Exception("Failed to fetch staff list: ${e.toString()}");
    }
  }

  //...................................Fetch Staff List................................
  static Future<Response> getStaffList() async {
    try {
      final userDetails = await AuthStorageService().getUserDetails();
      String userId = "";
      if (userDetails != null) {
        Map<String, dynamic> jsonData = jsonDecode(userDetails);
        userId = jsonData['id'];
      } else {
        // print("No user details found.");
      }
      final String fetchUrl = "$getStaffListByUserIdEndpoint/$userId";
      final response = await _dio.get(fetchUrl);
      return response;
    } catch (e) {
      throw Exception("Failed to fetch staff list: ${e.toString()}");
    }
  }

  //................................Fetch staff user details............................
  static Future<Response> getStaffUserDetails(final String id)async{
    try {
      final url = "$staffScheduleEndpoint/$id/schedule";
      final response = await _dio.get(url);
      return response;
    } catch (e) {
      throw Exception("Failed to fetch staff data: ${e.toString()}");
    }
  }

 //..................................Post staff user details............................
static Future<Response> postStaffUserDetails({
  required String id,
  required Map<String, dynamic> payload,
}) async {
  try {
    final url = "$staffScheduleEndpoint/$id/schedule";
    final response = await _dio.post(
      url,
      data: payload, // Pass the schedule data here
    );
    return response;
  } catch (e) {
    throw Exception("Failed to post staff data: ${e.toString()}");
  }
}

}
