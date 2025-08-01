import 'package:bookit_mobile_app/features/auth/presentation/forgotPasswordScreens/create_new_password_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/forgotPasswordScreens/otp_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/forgotPasswordScreens/signin_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/signup_verify_otp_screen.dart';
import 'package:bookit_mobile_app/features/main/calendar/presentation/add_new_client_screen.dart';
import 'package:bookit_mobile_app/features/main/calendar/presentation/book_new_appointment_screen.dart';
import 'package:bookit_mobile_app/features/main/calendar/presentation/book_new_appointment_screen_2.dart';
import 'package:bookit_mobile_app/features/main/calendar/presentation/view_all_appointments_screen.dart';
import 'package:bookit_mobile_app/features/main/dashboard/home_screen.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/presentation/add_staff_schedule_screen.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/presentation/add_staff_screen.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/presentation/add_class_schedule_screen.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/presentation/get_staff_list_screen.dart';
import 'package:bookit_mobile_app/features/main/home/presentation/setup_checklist_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/app_language_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/businessInformation/business_addresses_sceen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/businessInformation/business_hours_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/businessInformation/business_photo_gallery_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/businessInformation/name_email_phone_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/business_information_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/client_web_app_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/staff_members_screen.dart';
import 'package:bookit_mobile_app/features/main/menu/presentation/terms_and_conditions_screen.dart';
import 'package:bookit_mobile_app/features/main/offerings/presentation/add_service_details.dart';
import 'package:bookit_mobile_app/features/main/offerings/presentation/category_selection_screen.dart';
import 'package:bookit_mobile_app/features/main/offerings/presentation/select_services_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_about_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_finish_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_locations_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_offerings_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_add_services_details_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_welcome_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/onboard_add_service_screen.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/splash/presentation/splash_sceen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/signup_otp',
      builder: (context, state) {
        final data = state.extra as Map<String, String>? ?? {};
        return SignupVerifyOtpScreen(email: data['email'] ?? '');
      },
    ),
    GoRoute(
      path: '/forgetpassword',
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otpscreen',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? 'your email';
        return OtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/newpassword',
      builder: (context, state) => CreateNewPasswordScreen(),
    ),
    GoRoute(path: '/signin', builder: (context, state) => SigninScreen()),

    GoRoute(
      path: '/onboarding_welcome',
      builder: (context, state) => OnboardWelcomeScreen(),
    ),
    GoRoute(
      path: "/onboarding_about",
      builder: (context, state) => OnboardAboutScreen(),
    ),
    GoRoute(
      path: "/locations",
      builder: (context, state) => OnboardLocationsScreen(),
    ),
    GoRoute(
      path: "/offerings",
      builder: (context, state) => OnboardOfferingsScreen(),
    ),
    GoRoute(
      path: "/add_services",
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['category_id'] ?? '';
        return OnboardAddServiceScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: "/services_details",
      builder: (context, state) {
        return OnboardAddServicesDetailsScreen();
      },
    ),
    GoRoute(
      path: "/onboard_finish_screen",
      builder: (context, state) => OnboardFinishScreen(),
    ),

    //.....................dasboard..................
    GoRoute(path: "/home_screen", builder: (context, state) => HomeScreen()),

    //..................add staff screen....................
    GoRoute(
      path: "/add_staff", 
      builder: (context, state) {
        final isClass = state.uri.queryParameters['isClass'] == 'true';
        return AddStaffScreen(isClass: isClass);
      }
    ),

    //..................staff list screen..............
    GoRoute(
      path: "/staff_list",
      builder: (context, state) => GetStaffListScreen(),
    ),

    //................set staff schedule.............
    GoRoute(
      path: "/set_schedule",
      builder: (context, state){ 
        final data = state.extra as Map<String, dynamic>;
        final staffId = data['staffId'];
        return AddStaffScheduleScreen(staffId: staffId);
      },
    ),

    //.................View all appointments...........
    GoRoute(path: "/view_all_appointments", builder: (context, state) => ViewAllAppointmentsScreen(),),

    //..................Book new appointment...........
    GoRoute(path: "/book_new_appointment", builder: (context, state) => BookNewAppointmentScreen()),

    //.........Book new appointment screen 2 (add client)...
    GoRoute(path: "/book_new_appointment_add_client", builder: (context, state){
      final data = state.extra as Map<String, dynamic>;
      return BookNewAppointmentScreen2(partialPayload: data);
    },),

    //.........Add new client screen...
    GoRoute(path: "/add_new_client", builder: (context, state){
      final data = state.extra as Map<String, dynamic>;
      return AddNewClientScreen(partialPayload: data);
    },),

    //..................App Language Screen...........
    GoRoute(path: "/app_language", builder: (context, state) => const AppLanguageScreen()),

    //..................Setup Checklist Screen...........
    GoRoute(path: "/setup_checklist", builder: (context, state) => const SetupChecklistScreen()),

    //..................Category Selection Screen...........
    GoRoute(
      path: "/select_category",
      builder: (context, state) => const CategorySelectionScreen(),
    ),

    //..................Select Services Screen...........
    GoRoute(
      path: "/add_service_categories",
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'] ?? '';
        final categoryName = state.uri.queryParameters['categoryName'] ?? '';
        final isClass = state.uri.queryParameters['isClass'] == false;
        return SelectServicesScreen(
          categoryId: categoryId,
          categoryName: categoryName,
          isClass: isClass,
        );
      },
    ),

    //..................Add Class Schedule Screen...........
    GoRoute(
  path: "/add_class_schedule",
  builder: (context, state) {
    final extras = state.extra as Map<String, dynamic>?;

    return AddClassScheduleScreen(
      classId: extras?['classId'],
      className: extras?['className'],
    );
  },
),


    //..................Add offering service details.............
GoRoute(
  path: "/add_offering_service_details",
  builder: (context, state) {
    final payload = state.extra as Map<String, dynamic>?;
    return AddServiceDetailsScreen(servicePayload: payload);
  }
),
//..................Menu business information screen..............
    GoRoute(
      path: "/menu_business_information",
      builder: (context, state) => BusinessInformationScreen(),
    ),

//..................Menu business information screen..............
    GoRoute(
      path: "/menu_client_web_app",
      builder: (context, state) => ClientWebAppScreen(),
    ),

//................Business information name, email, phone screen..............
    GoRoute(
      path: "/business-information/name-email-phone",
      builder: (context, state) => NameEmailPhoneScreen(),
    ),

//.........................business photo gallery screen...............
    GoRoute(path: "/business-information/addresses", builder: (context, state) => BusinessAddressesScreen()),

//..................business hours screen..............
    GoRoute(path: "/business-information/business-hours", builder: (context, state) => BusinessHoursScreen()),

//.........................business photo gallary screen...............
    GoRoute(path: "/business-information/photo-gallery", builder: (context, state) => BusinessPhotoGalleryScreen()),

//..................List all staff members..............
    GoRoute(path: "/all_staff_members", builder: (context, state) => StaffMembersScreen()),

//..................Terms and Conditions screen..............
    GoRoute(path: "/terms_conditions", builder: (context, state) => const TermsAndConditionsScreen()),
  ],
);
