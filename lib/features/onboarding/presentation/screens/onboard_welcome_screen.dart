import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/shared/components/molecules/onboarding_checklist.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/scaffolds/onboard_scaffold_layout.dart';
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
  String nextRoute = "onboarding_about";
  bool isNextDisabled = true;
  String nextStep = "about";
  final List<Map<String, dynamic>> onboardingSteps = [
    {
      "id": "about_you",
      "step": 0,
      "heading": "About you",
      "subheading": "Get your business setup",
      "isCompleted": true,
    },
    {
      "id": "locations",
      "step": 1,
      "heading": "Locations",
      "subheading": "Where to find you",
      "isCompleted": true,
    },
    {
      "id": "services",
      "step": 2,
      "heading": "Your offerings",
      "subheading": "What you do",
      "isCompleted": false,
    },
    {
      "id": "categories",
      "step": 3,
      "heading": "Select services",
      "subheading": "Choose your bookable services",
      "isCompleted": false,
    },
    {
      "id": "service_details",
      "step": 4,
      "heading": "Services details",
      "subheading": "Describe what you offer",
      "isCompleted": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    getData();
  }
  

  void getData() async {

    final UserModel userData = await UserService().fetchUserDetails();

    if (userData.businessIds.isNotEmpty) {
      final String businessId = userData.businessIds[0];
      final businessDetails = await UserService().fetchBusinessDetails(
        businessId: businessId,
      );
      ref.read(businessProvider.notifier).state = businessDetails;

      int updatedStep = 0;
      switch (businessDetails.activeStep) {
        case "about_you":
          updatedStep = 0;
          nextRoute = "onboarding_about";
          break;
        case "locations":
          updatedStep = 1;
          nextRoute = "locations";
          break;
        case "categories":
          updatedStep = 2;
          nextRoute = "offerings";
          break;
        case "services":
          updatedStep = 3;
          nextRoute = "add_services";
          break;
        case "service_details":
          updatedStep = 4;
          nextRoute = "services_details";
          break;
      }

      setState(() {
        currentStep = updatedStep;
        isNextDisabled = false;
      });

    } 

    setState(() {
      isNextDisabled = false;
    });

  }

  @override 
  Widget build(BuildContext context) {
    final localizaitions = AppTranslationsDelegate.of(context);
    return OnboardScaffoldLayout(
      heading: localizaitions.text("onboard_welcome_title"),
      subheading: localizaitions.text("onboard_welcome_description"),
      backButtonDisabled: true,
      currentStep: -1,
      // nextButtonText: localizaitions.text(
      //   "onboard_welcome_next_button_about_you",
      // ),
      nextButtonText: "Next: ${nextStep.split('_').map((word) => word[0].toLowerCase() + word.substring(1)).join(' ')}",
      nextButtonDisabled: isNextDisabled,
      onNext: () {
        // context.push("/$nextRoute");
        context.push("/onboarding_about");
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
