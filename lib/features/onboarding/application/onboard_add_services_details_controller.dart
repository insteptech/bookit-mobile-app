import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/features/onboarding/widgets/onboard_services_form.dart';

class OnboardAddServicesDetailsController extends ChangeNotifier {
  final Ref ref;

  // State
  final Map<String, GlobalKey<OnboardServicesFormState>> _formKeys = {};
  bool _isButtonDisabled = false;
  String? _errorMessage;

  // Services
  final OnboardingApiService _onboardingApiService = OnboardingApiService();

  OnboardAddServicesDetailsController(this.ref);

  // Getters
  Map<String, GlobalKey<OnboardServicesFormState>> get formKeys => _formKeys;
  bool get isButtonDisabled => _isButtonDisabled;
  String? get errorMessage => _errorMessage;

  void addFormKey(String serviceId, GlobalKey<OnboardServicesFormState> key) {
    _formKeys[serviceId] = key;
  }

  Future<void> submitServiceDetails(BuildContext context) async {
    final business = ref.read(businessProvider);
    final businessId = business?.id;
    
    if (businessId == null) {
      _errorMessage = "Business ID not found";
      notifyListeners();
      return;
    }

    List<Map<String, dynamic>> allDetails = [];
    _isButtonDisabled = true;
    _errorMessage = null;
    notifyListeners();

    for (var key in _formKeys.values) {
      final state = key.currentState;
      if (state != null) {
        for (var form in state.getFormDataList()) {
          final json = form.toJson(businessId);
          if (json != null) {
            allDetails.add(json);
          }
        }
      }
    }

    try {
      await _onboardingApiService.updateService(allDetails: allDetails);
      
      if (context.mounted) {
        context.go("/onboard_finish_screen");
      }
    } catch (e) {
      _errorMessage = "Failed to update services";
      print(e); 
    } finally {
      _isButtonDisabled = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Provider for the add services details controller
final onboardAddServicesDetailsControllerProvider = ChangeNotifierProvider.autoDispose<OnboardAddServicesDetailsController>(
  (ref) => OnboardAddServicesDetailsController(ref),
);
