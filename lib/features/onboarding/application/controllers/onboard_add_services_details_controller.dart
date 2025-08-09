import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/widgets/onboard_services_form.dart';
import 'package:bookit_mobile_app/features/onboarding/data/data.dart';
import 'package:bookit_mobile_app/features/onboarding/application/providers.dart';

class OnboardAddServicesDetailsController extends ChangeNotifier {
  final Ref ref;
  late final OnboardingRepository _repository;

  // State
  final Map<String, GlobalKey<OnboardServicesFormState>> _formKeys = {};
  bool _isButtonDisabled = false;
  String? _errorMessage;

  OnboardAddServicesDetailsController(this.ref) {
    _repository = ref.read(onboardingRepositoryProvider);
  }

  // Getters
  Map<String, GlobalKey<OnboardServicesFormState>> get formKeys => _formKeys;
  bool get isButtonDisabled => _isButtonDisabled;
  String? get errorMessage => _errorMessage;

  void addFormKey(String serviceId, GlobalKey<OnboardServicesFormState> key) {
    _formKeys[serviceId] = key;
  }

  Future<void> submitServiceDetails(BuildContext context) async {
    final business = ref.read(businessProvider);
    if (business?.id == null) return;

    List<Map<String, dynamic>> allDetails = [];
    _isButtonDisabled = true;
    notifyListeners();

    for (var key in _formKeys.values) {
      final state = key.currentState;
      if (state != null) {
        for (var form in state.getFormDataList()) {
          final serviceData = form.toServiceData();
          if (serviceData != null) {
            allDetails.add(serviceData.toJson(business!.id));
          }
        }
      }
    }

    try {
      await _repository.updateService(allDetails: allDetails);
      
      if (context.mounted) {
        context.go("/onboard_finish_screen");
      }
    } catch (e) {
      _errorMessage = "Failed to update services";
      // TODO: Use proper logging instead of print
      // print(e); 
    } finally {
      _isButtonDisabled = false;
      notifyListeners();
    }
  }

  // Dispose is automatically called by ChangeNotifier
}
