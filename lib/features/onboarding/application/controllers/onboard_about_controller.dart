import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/onboarding_service.dart';
import 'package:bookit_mobile_app/core/utils/validators.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/features/onboarding/data/data.dart';
import 'package:bookit_mobile_app/features/onboarding/application/providers.dart';

class OnboardAboutController extends ChangeNotifier {
  final Ref ref;
  late final OnboardingRepository _repository;
  
  // Form state
  bool _isFormOpen = false;
  bool _isButtonDisabled = true;
  bool _isLoading = false;
  String _businessId = "";
  String? _errorMessage;

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  // Services
  final UserService _userService = UserService();
  final ActiveBusinessService _activeBusinessService = ActiveBusinessService();
  final OnboardingService _onboardingService = OnboardingService();

  OnboardAboutController(this.ref) {
    _repository = ref.read(onboardingRepositoryProvider);
    _initializeControllers();
    _initializeFromBusiness();
  }

  // Getters
  bool get isFormOpen => _isFormOpen;
  bool get isButtonDisabled => _isButtonDisabled;
  bool get isLoading => _isLoading;
  String get businessId => _businessId;
  String? get errorMessage => _errorMessage;

  void _initializeControllers() {
    nameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
    mobileController.addListener(_updateButtonState);
  }

  void _initializeFromBusiness() {
    final business = ref.read(businessProvider);
    if (business != null) {
      _isFormOpen = true;
      nameController.text = business.name;
      emailController.text = business.email;
      mobileController.text = business.phone;
      websiteController.text = business.website ?? '';
      _updateButtonState();
    }
  }

  void updateFormOpen(bool value) {
    _isFormOpen = value;
    _updateButtonState();
    notifyListeners();
  }

  void _updateButtonState() {
    if (!_isFormOpen) {
      _isButtonDisabled = true;
      notifyListeners();
      return;
    }

    final isValid = nameController.text.isNotEmpty &&
        isEmailInCorrectFormat(emailController.text) &&
        isMobileNumberInCorrectFormat(mobileController.text);

    if (_isButtonDisabled == isValid) {
      _isButtonDisabled = !isValid;
      notifyListeners();
    }
  }

  Future<void> handleBusinessInfoSubmission(BuildContext context) async {
    if (!_isFormOpen) return;
    
    _isLoading = true;
    _isButtonDisabled = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch user's business IDs
      final userData = await _userService.fetchUserDetails();
      _businessId = userData.businessIds.isNotEmpty ? userData.businessIds[0] : "";

      // Submit business info using repository
      final business = await _repository.submitBusinessInfo(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: mobileController.text.trim(),
        website: websiteController.text.trim(),
        businessId: _businessId,
      );

      _businessId = business.id;
      await _activeBusinessService.saveActiveBusiness(_businessId);

      // Fetch business details and save to global state
      try {
        final fetchBusinessDetails = await _userService.fetchBusinessDetails(
          businessId: _businessId,
        );
        ref.read(businessProvider.notifier).state = fetchBusinessDetails;
      } catch (e) {
        throw Exception("Failed to fetch business details: ${e.toString()}");
      }

      await _onboardingService.saveStep("about");

      // Navigate to next step
      if (context.mounted) {
        context.push('/locations');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      _isLoading = false;
      _isButtonDisabled = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}
