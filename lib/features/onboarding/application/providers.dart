import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/features/onboarding/data/data.dart';
import 'package:bookit_mobile_app/features/onboarding/application/controllers/onboard_about_controller.dart';
import 'package:bookit_mobile_app/features/onboarding/application/controllers/onboard_locations_controller.dart';
import 'package:bookit_mobile_app/features/onboarding/application/controllers/onboard_offerings_controller.dart';
import 'package:bookit_mobile_app/features/onboarding/application/controllers/onboard_add_service_controller.dart';
import 'package:bookit_mobile_app/features/onboarding/application/controllers/onboard_add_services_details_controller.dart';

// Data layer providers
final onboardingApiServiceProvider = Provider<OnboardingApiService>((ref) {
  return OnboardingApiService();
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final apiService = ref.watch(onboardingApiServiceProvider);
  return OnboardingRepositoryImpl(apiService);
});

// Controller providers
final onboardAboutControllerProvider = ChangeNotifierProvider.autoDispose<OnboardAboutController>(
  (ref) => OnboardAboutController(ref),
);

final onboardLocationsControllerProvider = ChangeNotifierProvider.autoDispose<OnboardLocationsController>(
  (ref) => OnboardLocationsController(ref),
);

final onboardOfferingsControllerProvider = ChangeNotifierProvider.autoDispose<OnboardOfferingsController>(
  (ref) => OnboardOfferingsController(ref),
);

final onboardAddServiceControllerProvider = ChangeNotifierProvider.autoDispose<OnboardAddServiceController>(
  (ref) => OnboardAddServiceController(ref),
);

final onboardAddServicesDetailsControllerProvider = ChangeNotifierProvider.autoDispose<OnboardAddServicesDetailsController>(
  (ref) => OnboardAddServicesDetailsController(ref),
);
