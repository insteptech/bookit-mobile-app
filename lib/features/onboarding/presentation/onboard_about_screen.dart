import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/core/utils/validators.dart';
import 'package:bookit_mobile_app/shared/components/molecules/onboard_business_info_form.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';

class OnboardAboutScreen extends ConsumerStatefulWidget {
  const OnboardAboutScreen({super.key});

  @override
  ConsumerState<OnboardAboutScreen> createState() => _OnboardAboutScreenState();
}

class _OnboardAboutScreenState extends ConsumerState<OnboardAboutScreen> {
  bool isFormOpen = false;
  bool isButtonDisabled = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  String businessId = "";

  @override
  void initState() {
    super.initState();
    nameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
    mobileController.addListener(_updateButtonState);

    final business = ref.read(businessProvider);
    if (business != null) {
      isFormOpen = true; // Show form by default
      nameController.text = business.name ?? '';
      emailController.text = business.email ?? '';
      mobileController.text = business.phone ?? '';
      websiteController.text = business.website ?? ''; 
    }
  }

  void _updateButtonState() {
    final isValid =
        nameController.text.isNotEmpty &&
        isEmailInCorrectFormat(emailController.text) &&
        mobileController.text.isNotEmpty;

    if (isButtonDisabled != !isValid) {
      setState(() {
        isButtonDisabled = !isValid;
      });
    }
  }

  Future<void> _handleBusinessInfoSubmission() async {
    if (!isFormOpen) return;
    setState(() {
      isButtonDisabled = true;
    });
    try {
      final onboardingApiService = OnboardingApiService();

      // fetch users business id's
      final userData = await UserService().fetchUserDetails();
      businessId = userData.businessIds.isNotEmpty ? userData.businessIds[0] : "";

      final business = await onboardingApiService.submitBusinessInfo(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: mobileController.text.trim(),
        website: websiteController.text.trim(),
        businessId: businessId,
      );

      businessId = business.id;
      await ActiveBusinessService().saveActiveBusiness(businessId);

      // fetch business details and save to global state
      try {
        final fetchBusinessDetails = await UserService().fetchBusinessDetails(businessId: businessId);
        
        ref.read(businessProvider.notifier).state = fetchBusinessDetails;
      } catch (e) {
        throw Exception("Failed to fetch business details: ${e.toString()}");
      }

      await OnboardingService().saveStep("about");

      // Navigate to next step
      if (!mounted) return;
      context.push('/locations');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppTranslationsDelegate.of(context);

    return OnboardScaffoldLayout(
      heading: localizations.text("onboard_about_title"),
      subheading: localizations.text("onboard_about_description"),
      backButtonDisabled: false,
      body: Column(
        children: [
          RadioButton(
            heading: localizations.text("onboard_about_radio_new_title"),
            description: localizations.text(
              "onboard_about_radio_new_description",
            ),
            bgColor: theme.scaffoldBackgroundColor,
            rememberMe: isFormOpen,
            onChanged: (value) {
              setState(() {
                isFormOpen = value;
              });
            },
            topRightLabel: "Coming soon",
          ),
          if (isFormOpen)
            const SizedBox(height: 16),
          if (isFormOpen)
            OnboardBusinessInfoForm(
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
              websiteController: websiteController,
            ),
          const SizedBox(height: 16),
          RadioButton(
            heading: localizations.text("onboard_about_radio_existing_title"),
            description: localizations.text(
              "onboard_about_radio_existing_description",
            ),
            bgColor: const Color(0xFF001948),
            rememberMe: false,
            onChanged: (value) {},
            topRightLabel: localizations.text(
              "onboard_about_radio_coming_soon_label",
            ),
            isDisabled: true,
          ),
        ],
      ),
      onNext: _handleBusinessInfoSubmission,
      nextButtonText: localizations.text("onboard_next_button_address_details"),
      nextButtonDisabled: isButtonDisabled,
      currentStep: 0,
    );
  }
}
