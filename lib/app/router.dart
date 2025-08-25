import 'package:bookit_mobile_app/features/auth/presentation/screens/forgot_password/create_new_password_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/screens/forgot_password/otp_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/screens/forgot_password/signin_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/screens/signup_verify_otp_screen.dart';
import 'package:bookit_mobile_app/features/calendar/presentation/view_all_appointments_screen.dart';
import 'package:bookit_mobile_app/features/calendar/presentation/view_all_schedule_screen.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/screens/appointments/book_new_appointment_screen.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/screens/appointments/book_new_appointment_screen_2.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/screens/clients/add_new_client_screen.dart';
import 'package:bookit_mobile_app/features/main/home_screen.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/add_staff_schedule_screen.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/add_staff_screen.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/add_class_schedule_screen.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/get_staff_list_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/setup_checklist_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/app_language_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/businessInformation/business_addresses_sceen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/businessInformation/business_hours_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/businessInformation/business_photo_gallery_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/businessInformation/name_email_phone_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/business_information_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/client_web_app_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/membership_status_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/staff_members_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/staff_category_selection_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/staff_category_screen.dart';
import 'package:bookit_mobile_app/features/menu/presentation/terms_and_conditions_screen.dart';
import 'package:bookit_mobile_app/features/offerings/presentation/add_service_details.dart';
import 'package:bookit_mobile_app/features/offerings/presentation/edit_offerings_screen.dart';
import 'package:bookit_mobile_app/features/offerings/presentation/category_selection_screen.dart';
import 'package:bookit_mobile_app/features/offerings/presentation/select_services_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_about_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_finish_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_locations_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_offerings_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_add_services_details_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_welcome_screen.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/screens/onboard_add_service_screen.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
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
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ForgotPasswordScreen(email: email);
      },
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
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return CreateNewPasswordScreen(email: email);
      },
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
    GoRoute(
      path: "/home_screen", 
      builder: (context, state) {
        final refresh = state.uri.queryParameters['refresh'] == 'true';
        return HomeScreen(refresh: refresh);
      }
    ),

    //..................add staff screen....................
    GoRoute(
      path: "/add_staff", 
      builder: (context, state) {
        final isClassParam = state.uri.queryParameters['isClass'];
        final buttonModeParam = state.uri.queryParameters['buttonMode'];
        final categoryId = state.uri.queryParameters['categoryId']; 
        final staffId = state.uri.queryParameters['staffId']; 
        final staffName = state.uri.queryParameters['staffName'];
        // Handle isClass parameter - null if not provided, bool if provided
        bool? isClass;
        if (isClassParam != null) {
          isClass = isClassParam == 'true';
        }
        // Handle buttonMode parameter
        StaffScreenButtonMode buttonMode = StaffScreenButtonMode.continueToSchedule;
        if (buttonModeParam == 'saveOnly') {
          buttonMode = StaffScreenButtonMode.saveOnly;
        }
        
        return AddStaffScreen(
          isClass: isClass, 
          buttonMode: buttonMode,
          categoryId: categoryId,
          staffId: staffId,
          staffName: staffName,
        );
      }
    ),

    //..................staff list screen..............
    GoRoute(
      path: "/staff_list",
      builder: (context, state) => GetStaffListScreen(),
    ),

    //..................staff category selection screen..............
    GoRoute(
      path: "/staff_category_selection",
      builder: (context, state) => const StaffCategorySelectionScreen(),
    ),

    //..................staff category screen..............
    GoRoute(
      path: "/staff_category",
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return StaffCategoryScreen(
          categoryId: data['categoryId'],
          categoryName: data['categoryName'],
          staffMembers: data['staffMembers'],
        );
      },
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
        final isClass = state.uri.queryParameters['isClass'] == 'true';
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

//..................Edit offerings screen..............
GoRoute(
  path: "/edit_offerings",
  builder: (context, state) {
    final serviceDetailId = state.uri.queryParameters['serviceDetailId'] ?? '';
    return EditOfferingsScreen(serviceDetailId: serviceDetailId);
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

//..................Membership status screen..............
    GoRoute(path: "/membership_status", builder: (context, state) => const MembershipStatusScreen()),
    
//.....................all classees screen.................
  GoRoute(path: "/all_classes_screen", builder: (context, state) => const ViewAllScheduleScreen(),)
  ],
);
