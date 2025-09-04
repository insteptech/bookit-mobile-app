import 'package:bookit_mobile_app/app/config.dart';

final String baseUrl = AppConfig.apiBaseUrl;

//..................................Auth Endpoints...................................
final businessSignupEndpoint = "$baseUrl/auth/business-register";
final verifyOtpEndpoint = "$baseUrl/auth/verify-otp";
final resendOtpEndpoint = "$baseUrl/auth/resend-otp";
final loginEndpoint = "$baseUrl/auth/login";
final profileEndpoint = "$baseUrl/auth/profile";
final refreshTokenEndpoint = "$baseUrl/auth/refresh-token";
final initiatePasswordResetEndpoint = "$baseUrl/auth/initiate-password-reset";
final verifyResetOtpEndpoint = "$baseUrl/auth/verify-reset-otp";
final resetPasswordEndpoint = "$baseUrl/auth/reset-password";
final changePasswordEndpoint = "$baseUrl/auth/change-password";
final socialLoginEndpoint = "$baseUrl/auth/social-login";

//.................................Business Onboarding................................
String businessDetailsEndpoint(String businessId) =>
    "$baseUrl/business/onboarding/$businessId";

//...................................staff endpoints..................................

final addStaffEndpoint = "$baseUrl/profile/staff/add";
final getUserRegisteredCategoriesEndpoint = "$baseUrl/auth"; //'id'/summary
final getStaffListByUserIdEndpoint = "$baseUrl/profile/staff/user";
final getStaffListEndpoint = "$baseUrl/profile/staff/list";
String getStaffListByBusinessIdEndpoint(String businessId) =>
    "$baseUrl/profile/staff/business/$businessId";

//..........................get staff in categories........................................
String getStaffListUnderCategoriesByBusinessIdEndpoint(String businessId) =>
    "$baseUrl/profile/staff/categories/$businessId";

//Get and post staff user details
final staffScheduleEndpoint = "$baseUrl/profile/staff"; //'staffUserId'/schedule' 

//........................get business level 0 categories...............................
String getBusinessLevel0CategoriesEndpoint(String businessId) =>
    "$baseUrl/business/$businessId/level0-categories";


//.................................Appointments.......................................
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

//.......................Create a new client accoutn............
String createClientAccountAndAppointmentEndpoint = "$baseUrl/profile/client-appointment";

//..........................Get business categories...................................
String getBusinessCategoriesEndpoint(String businessId) =>
    "$baseUrl/business/businesses/$businessId/categories";

//..........................Get business services...................................
String getBusinessServicesEndpoint(String businessId) =>
    "$baseUrl/business/$businessId/services/details";

//..........................Get business offerings...................................
String getBusinessOfferingsEndpoint(String businessId) =>
    "$baseUrl/business/$businessId/offerings";

//.........................Post offerings........................................
String postBusinessOfferingsEndpoint = "$baseUrl/business/offering";

//..........................Get all classes...................................
String getAllClassesEndpoint(String businessId) =>
    "$baseUrl/business/$businessId/classes";

//..........................Post classes details (staff and pricing)................
String postClassDetailsEndpoint = "$baseUrl/classes";



//..........................Get class details...................................
String getClassDetailsEndpoint(String classId) =>
    "$baseUrl/classes/$classId/details";

//,,...................Get all class schedules...................................
String getAllClassesFromBusinessEndpoint(String businessId) =>
    "$baseUrl/classes/business/$businessId";
//..........................Get class schedules by location......................
String getClassesByBusinessAndLocationEndpoint(String businessId, String locationId) =>
    "$baseUrl/classes/business/$businessId?locationId=$locationId";

//..........................Get class schedules by business and day......................
String getClassesByBusinessAndDayEndpoint(String businessId, String day) =>
    "$baseUrl/classes/business/$businessId?day=$day";

//..........................Get class schedules by business, location and day......................
String getClassesByBusinessLocationAndDayEndpoint(String businessId, String locationId, String day) =>
    "$baseUrl/classes/business/$businessId?locationId=$locationId&day=$day";

    String getPaginatedClassesByBusinessLocationAndDayEndpoint(String businessId, String locationId, String day, int page, int limit) =>
    "$baseUrl/classes/business/$businessId?locationId=$locationId&day=$day&page=$page&limit=$limit";

//...........Get paginated classes by Get paginated class schedules (page & limit)......................
String getPaginatedClassesByBusinessEndpoint(String businessId, int page, int limit) =>
    "$baseUrl/classes/business/$businessId?page=$page&limit=$limit";

//...........Get sorted classes by business (sortBy & sortOrder)......................
String getSortedClassesByBusinessEndpoint(String businessId, String sortBy, String sortOrder) =>
    "$baseUrl/classes/business/$businessId?sortBy=$sortBy&sortOrder=$sortOrder";

//...........Get specific class/service details
String getServiceDetailsByIdEndpoint(String serviceId) => 
    "$baseUrl/business/service-detail/$serviceId";



String addStaffWithScheduleEndpoint = "$baseUrl/profile/staff/add-with-schedule";

//..............get services and categories of the busines
String getServicesAndCategoriesOfBusinessEndpoint(String businessId, String categoryId) =>
    "$baseUrl/business/$businessId/services/comprehensive?categoryId=$categoryId";

String getStaffDetailsAndScheduleByIdEndpoint(String staffId, String businessId) =>
    "$baseUrl/profile/staff/$businessId/$staffId/comprehensive";

//................Save class and their shedule..........................
String saveClassAndScheduleEndpoint = "$baseUrl/classes/with-schedule";

//..................Get class and schedule data..........................
// String getClassAndScheduleDataEndpoint(String classId) => "$baseUrl/classes/$classId/with-schedules";
String getClassAndScheduleDataEndpoint(String classId) => "$baseUrl/classes/service-detail/$classId/complete";


//..............Delete staff / coach..................
String deleteStaffCoachEndpoint(String staffId) => "$baseUrl/profile/staff/$staffId";

//................cancel class / delete schedule class.................
String cancelClassEndpoint(String scheduleId, String classId) => "$baseUrl/schedules/classes/$classId/schedules/$scheduleId";

//.....................Delete class......................
String deleteClassEndpoint(String classId) => "$baseUrl/classes/$classId";

//....................Business Photo Gallery...................
String getBusinessGalleryPhotosEndpoint(String businessId) => "$baseUrl/business/$businessId/gallery";
String uploadBusinessGalleryPhotoEndpoint = "$baseUrl/business/gallery/upload";
String deleteBusinessGalleryPhotoEndpoint(String photoId) => "$baseUrl/business/gallery/$photoId";