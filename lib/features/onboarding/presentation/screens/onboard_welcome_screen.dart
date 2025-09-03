import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/shared/components/molecules/onboarding_checklist.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/scaffolds/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardWelcomeScreen({super.key});

  @override
  ConsumerState<OnboardWelcomeScreen> createState() => _OnboardWelcomeScreen();
}

class _OnboardWelcomeScreen extends ConsumerState<OnboardWelcomeScreen> {
  int currentStep = 0;
  String nextRoute = "/onboarding_about";
  bool isNextDisabled = true;
  String nextStep = "about";
  bool isLoading = true;
  
  final List<Map<String, dynamic>> onboardingSteps = [
    {
      "id": "about_you",
      "step": 0,
      "heading": "About you",
      "subheading": "Get your business setup",
      "route": "/about_you",
    },
    {
      "id": "locations",
      "step": 1,
      "heading": "Locations",
      "subheading": "Where to find you",
      "route": "/locations",
    },
    {
      "id": "categories",
      "step": 2,
      "heading": "Your offerings",
      "subheading": "What you do",
      "route": "/offerings",
    },
    {
      "id": "services",
      "step": 3,
      "heading": "Select services",
      "subheading": "Choose your bookable services",
      "route": "/add_services",
    },
    {
      "id": "service_details",
      "step": 4,
      "heading": "Services details",
      "subheading": "Describe what you offer",
      "route": "/services_details",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeWelcomeData();
  }

  void _initializeWelcomeData() async {
    final business = ref.read(businessProvider);
    
    if (business == null) {
      try {
        final userService = UserService();
        final userData = await userService.fetchUserDetails();
        if (userData.businessIds.isNotEmpty) {
          final businessData = await userService.fetchBusinessDetails(
            businessId: userData.businessIds[0]
          );
          ref.read(businessProvider.notifier).state = businessData;
          _setCurrentStepFromBusiness(businessData);
        } else {
          _setDefaultStep();
        }
      } catch (e) {
        print("Failed to fetch business data: $e");
        _setDefaultStep();
      }
    } else {
      _setCurrentStepFromBusiness(business);
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
      isNextDisabled = false;
    });
  }

  void _setCurrentStepFromBusiness(business) {
    print("Business active step: ${business.activeStep}");
    for(int i=0; i<onboardingSteps.length; i++){
      if(onboardingSteps[i]['id'] == business.activeStep){
        setState(() {
          currentStep = i;
          nextRoute = onboardingSteps[i]['route'];
          nextStep = onboardingSteps[i]['id'];
        });
        break;  
      }
    }
  }

  void _setDefaultStep() {
    setState(() {
      currentStep = 0;
      nextStep = onboardingSteps[currentStep]['id'];
    });
  }

  @override 
  Widget build(BuildContext context) {
    final localizations = AppTranslationsDelegate.of(context);
    
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return OnboardScaffoldLayout(
      heading: localizations.text("onboard_welcome_title"),
      subheading: localizations.text("onboard_welcome_description"),
      physics: const ClampingScrollPhysics(),
      contentPadding: EdgeInsets.fromLTRB(AppConstants.defaultHorizontalPadding, 0, AppConstants.defaultHorizontalPadding, 0),
      backButtonDisabled: true,
      currentStep: -1,
      nextButtonText: "Next: ${nextStep.split('_').map((word) => word[0].toLowerCase() + word.substring(1)).join(' ')}",
      nextButtonDisabled: isNextDisabled,
      onNext: () {
        context.push(nextRoute);
      },
      body: Column(
        children:
            onboardingSteps
                .map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: OnboardingChecklist(
                      heading: step["heading"],
                      subHeading: step["subheading"],
                      isCompleted: step["step"] < currentStep,
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
