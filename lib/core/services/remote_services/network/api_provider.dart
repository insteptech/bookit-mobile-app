import 'dart:convert';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/endpoint.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/dio_client.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// APIRepository handles all API calls related to staff management, including adding multiple staff members, fetching staff lists, and managing staff schedules.

class APIRepository {
  static final Dio _dio = DioClient.instance;

  //.................................Add Multiple Staff.............................
  /// Adds multiple staff profiles to the system.
  static Future<Response> addMultipleStaff({
    required List<StaffProfile> staffProfiles,
  }) async {
    // Get user ID
    String userId = "";
    String businessId = "";
    try {
      final userDetails = await AuthStorageService().getUserDetails();
      userId = userDetails.id;
      businessId = userDetails.businessIds[0];
    } catch (e) {
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
          profileJson['business_id'] = businessId;

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

  //...........................Add staff with schedule..............................
  static Future<Response> addStaffWithSchedule(
    Map<String, dynamic> payload
  ) async {
    try {
      final response = await _dio.post(
        addStaffWithScheduleEndpoint,
        data: payload
      );
      print(response);
      return response;
    } catch (e) {
      print("Error while creating the staff and scheudle: $e");
      throw Exception("Failed to create staff and schedule: $e");
    }
  }

  //..........................Fetch User Data for Staff Registration..................

  static Future<Response> getBusinessLevel0Categories()async {
    try {
      final userDetails = await AuthStorageService().getUserDetails();
      String userId = userDetails.id;
            String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;

      // final String fetchUrl =
      //     "$getUserRegisteredCategoriesEndpoint/$userId/summary";
       final String fetchUrl =
          getBusinessLevel0CategoriesEndpoint(businessId);
      final response = await _dio.get(fetchUrl); 
    //             final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from get staff list:\n$prettyJson");
      return response;
    } catch (e) {
      throw Exception("Failed to fetch staff list: ${e.toString()}");
    }
  }

  //............................get services and categories of the business.............
  static Future<Response> getServicesAndCategoriesOfBusiness(String categoryId) async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final String fetchUrl =
          getServicesAndCategoriesOfBusinessEndpoint(businessId, categoryId);
      final response = await _dio.get(fetchUrl); 
            //        // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from getServicesAndCategoriesOfBusiness:\n$prettyJson");
      return response;
    } catch (e) {
      throw Exception("Failed to fetch services and categories: ${e.toString()}");
    }
  }

  //...................................Fetch Staff List................................
  static Future<Response> getStaffList() async {
    try {
      final userDetails = await AuthStorageService().getUserDetails();
      String userId = userDetails.id;
      print("User id: $userId");

      final String fetchUrl = "$getStaffListByUserIdEndpoint/$userId";
      final response = await _dio.get(fetchUrl);
    //       final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from get staff list:\n$prettyJson");

      return response;
    } catch (e) {
      throw Exception("Failed to fetch staff list: ${e.toString()}");
    }
  }

  //................................Fetch staff user details............................
  static Future<Response> getStaffUserDetails(final String id) async {
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

  //...............................Get business locations.................................
  static Future<Map<String, dynamic>> getBusinessLocations() async {
    try {
      final userDetails = await UserService().fetchUserDetails();
      String businessId = userDetails.businessIds[0];

      String url = getBusinessLocationsEndpoint(businessId);

      final response = await _dio.get(url);
          //        // Pretty print JSON
    // final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from getBusinessLocations:\n$prettyJson");
      return response.data['data'];
    } catch (e) {
      throw Exception("failed to fetch locations ${e.toString()}");
    }
  }

  //...................................Fetch appointments..................................
  static Future<Map<String, dynamic>> getAppointments(String locationId) async {
    try {
      final url = fetchAppointmentsEndpoint(locationId);
      final response = await _dio.get(url);
          //        // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from get appointments:\n$prettyJson");


      return response.data['data'];
    } catch (e) {
      throw Exception("failed to fetch appointments ${e.toString()}");
    }
  }

  //.......................Practitionaer (staff) based on location........................
  static Future<Map<String, dynamic>> getPractitioners(
    String locationId,
  ) async {
    try {
      final url = getPractitionersBasedOnLocationEndpoint(locationId);

      final response = await _dio.get(url);

      return response.data['data'];
    } catch (e) {
      throw Exception("failed to fetch practitioners ${e.toString()}");
    }
  }

  //............................get service details from business ID.......................
  static Future<Map<String, dynamic>> getServiceList() async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getServiceListListFromBusiness(businessId);

      final response = await _dio.get(url);

      //        // Pretty print JSON
      // final encoder = const JsonEncoder.withIndent('  ');
      // final prettyJson = encoder.convert(response.data);
      // debugPrint("Full response from getServiceList:\n$prettyJson");

      return response.data;
    } catch (e) {
      throw Exception("failed to fetch service list ${e.toString()}");
    }
  }

  //..............................fetch clients..............................
  static Future<Map<String, dynamic>> fetchClients({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final url = getClientSearchUrl(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch clients: ${e.toString()}");
    }
  }

  //..............................Book appointment..............................
  static Future<Response> bookAppointment({
    required List<Map<String, dynamic>> payload,
  }) async {
    try {
      final response = await _dio.post(bookAppointmentEndpoint, data: payload);
      return response;
    } catch (e) {
      throw Exception("Failed to book appointment: ${e.toString()}");
    }
  }

  //..............................Create a new client account.......................
  static Future<Response> createClientAccountAndBookAppointment({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        createClientAccountAndAppointmentEndpoint,
        data: payload,
      );
      return response;
    } catch (e) {
      throw Exception("Failed to create client account: ${e.toString()}");
    }
  }

  //............................Get business categories..............................
  static Future<Map<String, dynamic>> getBusinessCategories() async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getBusinessCategoriesEndpoint(businessId);
      final response = await _dio.get(url);

      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch business categories: ${e.toString()}");
    }
  }


  //............................Get business services..................................
  static Future<Map<String, dynamic>> getBusinessServiceCategories() async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getBusinessServicesEndpoint(businessId);
      final response = await _dio.get(url);
          //        // Pretty print JSON
    // final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from getBusinessOfferings:\n$prettyJson");
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch business offerings: ${e.toString()}");
    }
  }

  //............................Get business offerings (offering screen)..................................
  static Future<Map<String, dynamic>> getBusinessOfferings() async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getBusinessOfferingsEndpoint(businessId);
      final response = await _dio.get(url);
          //        // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from getBusinessOfferings:\n$prettyJson");
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch business offerings: ${e.toString()}");
    }
  }

  //............................Get staff list........................................
  static Future<Response> getAllStaffList() async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getStaffListUnderCategoriesByBusinessIdEndpoint(businessId);
      // final response = await _dio.get(getStaffListEndpoint);
      final response = await _dio.get(url);

                 // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from getAllStaffList:\n$prettyJson");
        return response;

    }
    catch (e) {
      throw Exception("Failed to fetch staff list: ${e.toString()}");
    }
  }

  //....................Get staff details and schedule by staff ID........................................
  static Future<Response> getStaffDetailsAndScheduleById(String staffId) async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getStaffDetailsAndScheduleByIdEndpoint(staffId, businessId);
      final response = await _dio.get(url);
              // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from getStaffDetailsAndScheduleById:\n$prettyJson");
        return response;

    }
    catch (e) {
      throw Exception("Failed to fetch staff details: ${e.toString()}");
    }
  }

    //............................Get staff list........................................
  static Future<Response> getStaffListByBusinessId() async {
    try {
       String businessId =
        await ActiveBusinessService().getActiveBusiness() as String;
      final response = await _dio.get(getStaffListByBusinessIdEndpoint(businessId));

    //              // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from getStaffListByBusinessId:\n$prettyJson");
        return response;

    }
    catch (e) {
      throw Exception("Failed to fetch staff list: ${e.toString()}");
    }
  }

  //............................Post business offerings.................................
  static Future<Response> postBusinessOfferings({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        postBusinessOfferingsEndpoint,
        data: payload,
      );
      return response;
    } catch (e) {
      throw Exception("Failed to post business offerings: ${e.toString()}");
    }
  }

  //............................Get all classes.......................................

static Future<Map<String, dynamic>> getAllClasses() async {
  try {
    String businessId =
        await ActiveBusinessService().getActiveBusiness() as String;
    final url = getAllClassesEndpoint(businessId);
    final response = await _dio.get(url);
    //        // Pretty print JSON
    // final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from getAllClasses:\n$prettyJson");
    return response.data;
  } catch (e) {
    throw Exception("Failed to fetch classes: ${e.toString()}");
  }
}

//............................Post class details (staff and pricing)................
static Future<Response> postClassDetails({
  required Map<String, dynamic> payload,
}) async {
  try {
    final response = await _dio.post(
      postClassDetailsEndpoint,
      data: payload,
    );
    return response;
  } catch (e) {
    throw Exception("Failed to post class details: ${e.toString()}");
  }
}

  //............................Get class details.....................................
  static Future<Map<String, dynamic>> getClassDetails(String classId) async {
    try {
      final url = getClassDetailsEndpoint(classId);
      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch class details: ${e.toString()}");
    }
  }

// //........................Get all classes based on location.........................
// static Future<Map<String, dynamic>> getAllClassesDetails() async {
//   try {
//     String businessId =
//         await ActiveBusinessService().getActiveBusiness() as String;
//     final url = getAllClassesFromBusinessEndpoint(businessId);
//     final response = await _dio.get(url);
//     print("Response from getClassesByLocation: ${response.data}");
//     return response.data;
//   } catch (e) {
//     throw Exception("Failed to fetch classes by location: ${e.toString()}");
//   }
// }
static Future<Map<String, dynamic>> getAllClassesDetails() async {
  try {
    String businessId =
        await ActiveBusinessService().getActiveBusiness() as String;

    final url = getAllClassesFromBusinessEndpoint(businessId);
    final response = await _dio.get(url);
              //        // Pretty print JSON
    // final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from getAllClassesDetails:\n$prettyJson");
    return response.data;
  } catch (e, stacktrace) {
    debugPrint("Error in getAllClassesDetails: $e");
    debugPrint("Stacktrace: $stacktrace");
    throw Exception("Failed to fetch classes by location: ${e.toString()}");
  }
}
static Future<Map<String, dynamic>> getClassSchedulesByLocationAndDay(
    String locationId,
    String day
  ) async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getClassesByBusinessLocationAndDayEndpoint(businessId, locationId, day);
      final response = await _dio.get(url);
                    //        // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from class schedule location and day:\n$prettyJson");
   
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch class schedules: ${e.toString()}");
    }
  }

  /// Cancels a class schedule (dummy implementation)
  static Future<Map<String, dynamic>> cancelClass(String classId) async {
    try {
      // Dummy implementation - simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint("Cancelling class with ID: $classId");
      
      // Return success response
      return {
        "success": true,
        "message": "Class cancelled successfully",
        "data": {
          "classId": classId,
          "status": "cancelled"
        }
      };
    } catch (e) {
      debugPrint("Error cancelling class: $e");
      throw Exception("Failed to cancel class: ${e.toString()}");
    }
  }

  /// Deletes a class (dummy implementation)
  static Future<Response> deleteClass(String classId) async {
    try {
      // Dummy implementation - simulate API call
      // await Future.delayed(const Duration(milliseconds: 800));
      
      // debugPrint("Deleting class with ID: $classId");
      
      // // Return success response
      // return {
      //   "success": true,
      //   "message": "Class deleted successfully",
      //   "data": {
      //     "classId": classId,
      //     "status": "deleted"
      //   }
      // };
      final response = await _dio.delete(deleteClassEndpoint(classId));
      return response;
    } catch (e) {
      debugPrint("Error deleting class: $e");
      throw Exception("Failed to delete class: ${e.toString()}");
    }
  }

  static Future<Map<String, dynamic>> getClassScheduleByPaginationAndLocationAndDay(
    int page,
    int limit,
    String locationId,
    String day,
  ) async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getPaginatedClassesByBusinessLocationAndDayEndpoint(businessId, locationId, day, page, limit);
      final response = await _dio.get(url);
                    //        // Pretty print JSON
    // final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from $url:\n$prettyJson");
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch class schedules: ${e.toString()}");
    }
  }

  static Future<Map<String, dynamic>> getClassesByBusinessAndDay(
    String day,
  ) async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getClassesByBusinessAndDayEndpoint(businessId, day);
      final response = await _dio.get(url);
                    //        // Pretty print JSON
    // final encoder = const JsonEncoder.withIndent('  ');
    // final prettyJson = encoder.convert(response.data);
    // debugPrint("Full response from get class from business and day:\n$prettyJson");
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch classes by business and location: ${e.toString()}");
    }
  }

  static Future<Map<String, dynamic>> getClassScheduleByPagination(
    int page,
    int limit,
  ) async {
    try {
      String businessId =
          await ActiveBusinessService().getActiveBusiness() as String;
      final url = getPaginatedClassesByBusinessEndpoint(businessId, page, limit);
      final response = await _dio.get(
        url,
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch class schedules by pagination: ${e.toString()}");
    }
  }

  //............................Get class/service details by ID..............................
  static Future<Map<String, dynamic>> getServiceDetailsById(String serviceId) async {
    try {
      final url = getServiceDetailsByIdEndpoint(serviceId);
      final response = await _dio.get(url);
          //        // Pretty print JSON
    final encoder = const JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(response.data);
    debugPrint("Full response from getServiceDetailsById:\n$prettyJson");
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch service details: ${e.toString()}");
    }
  }

  //............................Put class/service details by ID..............................
  static Future<Map<String, dynamic>> updateServiceDetails(String serviceId, Map<String, dynamic> data) async {
    try {
      final url = getServiceDetailsByIdEndpoint(serviceId);
      final response = await _dio.put(url, data: data);
      //        // Pretty print JSON
      final encoder = const JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(response.data);
      debugPrint("Full response from updateServiceDetails:\n$prettyJson");
      return response.data;
    } catch (e) {
      throw Exception("Failed to update service details: ${e.toString()}");
    }
  }

  //............................Forgot Password Methods..............................
  /// Initiates password reset by sending OTP to email
  static Future<void> initiatePasswordReset({required String email}) async {
    try {
      final authService = AuthService();
      await authService.initiatePasswordReset(email: email);
    } catch (e) {
      throw Exception("Failed to initiate password reset: ${e.toString()}");
    }
  }

  /// Verifies OTP for password reset
  static Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final authService = AuthService();
      await authService.verifyResetOtp(email: email, otp: otp);
    } catch (e) {
      throw Exception("Failed to verify reset OTP: ${e.toString()}");
    }
  }

  /// Resets password with new password
  static Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final authService = AuthService();
      await authService.resetPassword(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      throw Exception("Failed to reset password: ${e.toString()}");
    }
  }

  //...................Save classess and its schedule...............
    static Future<Response> saveClassAndSchedule({
    required List<Map<String, dynamic>> payload,
  }) async {
    try {
      final response = await _dio.post(
        saveClassAndScheduleEndpoint, 
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response;
    } catch (e) {
      throw Exception("Failed to save class and schedule: ${e.toString()}");
    }
  }

  //..................Get class and schedule ......................
  static Future<Response> getClassAndSchedule(String classId){
    try {
      final response = _dio.get(getClassAndScheduleDataEndpoint(classId));
      return response;
    } catch (e) {
      throw Exception("Error fetching data $e");
    }
  }

  //..................Delete staff/coach......................
  static Future<Response> deleteStaff(String staffId) async {
    try {
      final response = await _dio.delete(
        deleteStaffCoachEndpoint(staffId),
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      return response; 
    } catch (e) {
      throw Exception("Failed to delete staff: ${e.toString()}");
    }
  }

}