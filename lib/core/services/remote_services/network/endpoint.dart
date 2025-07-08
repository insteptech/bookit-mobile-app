import 'package:bookit_mobile_app/app/config.dart';

final String baseUrl = AppConfig.apiBaseUrl;

//..................................Auth Endpoints...................................
final businessSignupEndpoint = "$baseUrl/auth/business-register";
final verifyOtpEndpoint = "$baseUrl/auth/verify-otp";
final resendOtpEndpoint = "$baseUrl/auth/resend-otp";
final loginEndpoint = "$baseUrl/auth/login";
final profileEndpoint = "$baseUrl/auth/profile";

//.................................Business Onboarding................................
String businessDetailsEndpoint(String businessId) =>
    "$baseUrl/business/onboarding/$businessId";

//...................................staff endpoints..................................

final addStaffEndpoint = "$baseUrl/profile/staff/add";
final getUserRegisteredCategoriesEndpoint = "$baseUrl/auth"; //'id'/summary
final getStaffListByUserIdEndpoint = "$baseUrl/profile/staff/user";

//Get and post staff user details
final staffScheduleEndpoint = "$baseUrl/profile/staff"; //'staffUserId'/schedule' 
