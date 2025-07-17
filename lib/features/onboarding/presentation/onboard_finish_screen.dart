import 'package:bookit_mobile_app/core/models/user_model.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:bookit_mobile_app/shared/components/molecules/onboarding_checklist.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardFinishScreen extends ConsumerStatefulWidget {
  const OnboardFinishScreen({super.key});

  @override
  ConsumerState<OnboardFinishScreen> createState() => _OnboardFinishScreenState();
}

class _OnboardFinishScreenState extends ConsumerState<OnboardFinishScreen> {
  int currentStep = 0;
  bool isLoading = true;

  final List<Map<String, dynamic>> onboardingSteps = [
    {
      "id": "about_you",
      "step": 0,
      "heading": "About you",
      "subheading": "Get your business setup",
    },
    {
      "id": "locations",
      "step": 1,
      "heading": "Locations",
      "subheading": "Where to find you",
    },
    {
      "id": "services",
      "step": 2,
      "heading": "Your offerings",
      "subheading": "What you do",
    },
    {
      "id": "categories",
      "step": 3,
      "heading": "Select services",
      "subheading": "Choose your bookable services",
    },
    {
      "id": "service_details",
      "step": 4,
      "heading": "Services details",
      "subheading": "Describe what you offer",
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final token = await TokenService().getToken();
    final UserModel userData = await UserService().fetchUserDetails();

    if (userData.businessIds.isNotEmpty) {
      final businessId = userData.businessIds[0];
      final businessDetails = await UserService().fetchBusinessDetails(businessId: businessId);
      ref.read(businessProvider.notifier).state = businessDetails;

      int updatedStep = 0;
      switch (businessDetails.activeStep) {
        case "about_you":
          updatedStep = 0;
          break;
        case "locations":
          updatedStep = 1;
          break;
        case "services":
          updatedStep = 2;
          break;
        case "categories":
          updatedStep = 3;
          break;
        case "service_details":
          updatedStep = 4;
          break;
        default:
          updatedStep = 5;
      }

      setState(() {
        currentStep = updatedStep;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardScaffoldLayout(
      heading: "You're all set!",
      subheading: "Your business is ready to go.",
      backButtonDisabled: true,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: onboardingSteps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: OnboardingChecklist(
                        heading: step["heading"],
                        subHeading: step["subheading"],
                        isCompleted: step["step"] <= currentStep,
                      ),
                    ),
                  )
                  .toList(),
            ),
      onNext: () {
        context.go("/home_screen");
      },
      nextButtonText: "Go to dashboard",
      nextButtonDisabled: false,
      currentStep: 4,
    );
  }
}
