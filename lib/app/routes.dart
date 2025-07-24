/// Route constants for type-safe navigation throughout the app
/// This helps prevent typos and makes route management centralized
class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupOtp = '/signup_otp';
  static const String forgotPassword = '/forgetpassword';
  static const String otpScreen = '/otpscreen';
  static const String newPassword = '/newpassword';
  static const String signin = '/signin';

  // Onboarding routes
  static const String onboardingWelcome = '/onboarding_welcome';
  static const String onboardingAbout = '/onboarding_about';
  static const String locations = '/locations';
  static const String offerings = '/offerings';
  static const String addServices = '/add_services';
  static const String servicesDetails = '/services_details';
  static const String onboardFinish = '/onboard_finish_screen';

  // Main app routes
  static const String homeScreen = '/home_screen';
  static const String addStaff = '/add_staff';
  static const String staffList = '/staff_list';
  static const String addClassSchedule = '/add_class_schedule';
  static const String setSchedule = '/set_schedule';
  static const String viewAllAppointments = '/view_all_appointments';
  static const String bookNewAppointment = '/book_new_appointment';
  static const String bookNewAppointmentAddClient = '/book_new_appointment_add_client';
  static const String addNewClient = '/add_new_client';

  // Offerings routes
  static const String addServiceCategories = '/add_service_categories';
  static const String addService = '/add_service';

  // Menu routes
  static const String appLanguage = '/app_language';

  // Route validation
  static const List<String> _allRoutes = [
    splash, login, signup, signupOtp, forgotPassword, otpScreen, newPassword, signin,
    onboardingWelcome, onboardingAbout, locations, offerings, addServices, servicesDetails, onboardFinish,
    homeScreen, addStaff, staffList, addClassSchedule, setSchedule, viewAllAppointments, bookNewAppointment, 
    bookNewAppointmentAddClient, addNewClient, addServiceCategories, addService, appLanguage,
  ];

  /// Check if a route is valid
  static bool isValidRoute(String route) {
    return _allRoutes.contains(route.split('?').first); // Remove query parameters for validation
  }

  /// Get all available routes
  static List<String> get allRoutes => List.unmodifiable(_allRoutes);
}

/// Extension methods for commonly used navigation patterns
extension AppRoutesExtension on AppRoutes {
  /// Get route with query parameters
  static String otpScreenWithEmail(String email) => '${AppRoutes.otpScreen}?email=$email';
  
  /// Get route with category ID
  static String addServicesWithCategory(String categoryId) => '${AppRoutes.addServices}?category_id=$categoryId';
  
  /// Get add staff route with optional isClass parameter
  static String addStaffWithType({bool isClass = false}) => '${AppRoutes.addStaff}?isClass=$isClass';
  
  /// Get add service route with category parameters
  static String addServiceWithCategory({required String categoryId, required String categoryName}) => 
    '${AppRoutes.addService}?categoryId=$categoryId&categoryName=${Uri.encodeComponent(categoryName)}';
}
