import 'package:bookit_mobile_app/app/config.dart';

final String baseUrl = AppConfig.apiBaseUrl;

//..................................Auth Endpoints...................................
final businessSignupEndpoint = "$baseUrl/auth/business-register";
final verifyOtpEndpoint = "$baseUrl/auth/verify-otp";
final resendOtpEndpoint = "$baseUrl/auth/resend-otp";
final loginEndpoint = "$baseUrl/auth/login";
final profileEndpoint = "$baseUrl/auth/profile";
final refreshTokenEndpoint = "$baseUrl/auth/refresh-token";

//.................................Business Onboarding................................
String businessDetailsEndpoint(String businessId) =>
    "$baseUrl/business/onboarding/$businessId";

//...................................staff endpoints..................................

final addStaffEndpoint = "$baseUrl/profile/staff/add";
final getUserRegisteredCategoriesEndpoint = "$baseUrl/auth"; //'id'/summary
final getStaffListByUserIdEndpoint = "$baseUrl/profile/staff/user";

//Get and post staff user details
final staffScheduleEndpoint = "$baseUrl/profile/staff"; //'staffUserId'/schedule' 


//.................................Appointments.......................................]
String getBusinessLocationsEndpoint(String businessId) =>
    "$baseUrl/business/businesses/$businessId/locations";

String fetchAppointmentsEndpoint(String locationId)=>
    "$baseUrl/appointments/location/$locationId";

//.......................Practitionaer (staff) based on location........................
String getPractitionersBasedOnLocationEndpoint(String locationId) =>
    "$baseUrl/profile/staff/location/$locationId";

//............................service list based on business............................
String getServiceListListFromBusiness(String businessId) =>
    "$baseUrl/business/$businessId/services";

//............................Fetch clients....................................
String getClientSearchUrl({
  String? fullName,
  String? email,
  String? phoneNumber,
}) {
  String base = "$baseUrl/profile/client/filter?";
  List<String> params = [];

  if (fullName != null && fullName.isNotEmpty) {
    params.add("full_name=$fullName");
  }
  if (email != null && email.isNotEmpty) {
    params.add("email=$email");
  }
  if (phoneNumber != null && phoneNumber.isNotEmpty) {
    params.add("phone_number=$phoneNumber");
  }

  return base + params.join("&");
}

//..........................Book appointment.......................................
String bookAppointmentEndpoint = "$baseUrl/appointments";

