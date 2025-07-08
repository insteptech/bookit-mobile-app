import 'package:bookit_mobile_app/features/auth/presentation/forgotPasswordScreens/create_new_password_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/forgotPasswordScreens/otp_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/forgotPasswordScreens/signin_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:bookit_mobile_app/features/auth/presentation/signup_verify_otp_screen.dart';
import 'package:bookit_mobile_app/features/main/home/home_screen.dart';
import 'package:bookit_mobile_app/features/main/home/staff/presentation/add_staff_schedule_screen.dart';
import 'package:bookit_mobile_app/features/main/home/staff/presentation/add_staff_screen.dart';
import 'package:bookit_mobile_app/features/main/home/staff/presentation/get_staff_list_screen.dart';
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
    GoRoute(path: "/add_staff", builder: (context, state) => AddStaffScreen()),

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
  ],
);
