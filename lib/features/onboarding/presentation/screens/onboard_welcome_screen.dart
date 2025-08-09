import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
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
  bool isLoading = true;
  
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
    _initializeWelcomeData();
  }

  void _initializeWelcomeData() async {
    // TODO: This should be moved to a controller that uses the repository
    // For now, keeping minimal changes to preserve functionality
    setState(() {
      isLoading = false;
      isNextDisabled = false;
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
      backButtonDisabled: true,
      currentStep: -1,
      nextButtonText: "Next: ${nextStep.split('_').map((word) => word[0].toLowerCase() + word.substring(1)).join(' ')}",
      nextButtonDisabled: isNextDisabled,
      onNext: () {
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
