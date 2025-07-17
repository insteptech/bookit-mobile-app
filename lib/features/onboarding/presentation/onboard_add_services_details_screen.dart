import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_services_form.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardAddServicesDetailsScreen extends ConsumerStatefulWidget {
  const OnboardAddServicesDetailsScreen({super.key});

  @override
  ConsumerState<OnboardAddServicesDetailsScreen> createState() => _OnboardAddServicesDetailsScreenState();
}

class _OnboardAddServicesDetailsScreenState extends ConsumerState<OnboardAddServicesDetailsScreen> {
  final Map<String, GlobalKey<OnboardServicesFormState>> formKeys = {};
  bool isButtonDisabled = false;

  Future<void> submitServiceDetails(String businessId) async {
    List<Map<String, dynamic>> allDetails = [];
    setState(() {
      isButtonDisabled= true;
    });
    for (var key in formKeys.values) {
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
    await OnboardingApiService().updateService(allDetails: allDetails);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider);
    final services = business?.businessServices ?? [];

    final level1 = services.where((s) => s.category.level == 1).toList();
    final level2 = services.where((s) => s.category.level == 2).toList();

    final Map<String, List<dynamic>> level1ToLevel2 = {};
    for (var s in level2) {
      final parent = s.category.parentId;
      if (parent != null) {
        level1ToLevel2.putIfAbsent(parent, () => []).add(s);
      }
    }

    return OnboardScaffoldLayout(
      heading: "Services details",
      subheading:
          "Great! Now, let's add some detail to those services. Describe each one as you'd like your clients to see it.",
      backButtonDisabled: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l1 in level1) ...[
            Text(l1.category.name, style: AppTypography.headingMd),
            const SizedBox(height: 8),
            if (level1ToLevel2.containsKey(l1.category.id))
              for (final l2 in level1ToLevel2[l1.category.id]!) ...[
                Text(l2.category.name, style: AppTypography.headingSm),
                const SizedBox(height: 8),
                Builder(builder: (context) {
                  final key = GlobalKey<OnboardServicesFormState>();
                  formKeys[l2.id] = key;
                  return OnboardServicesForm(key: key, serviceId: l2.id);
                }),
                const SizedBox(height: 24),
              ]
            else ...[
              Builder(builder: (context) {
                final key = GlobalKey<OnboardServicesFormState>();
                formKeys[l1.id] = key;
                return OnboardServicesForm(key: key, serviceId: l1.id);
              }),
              const SizedBox(height: 24),
            ],
          ]
        ],
      ),
      onNext: () async {
        if (business?.id != null) {
          await submitServiceDetails(business!.id);
          context.go("/onboard_finish_screen");
        }
      },
      nextButtonText: "Finish",
      nextButtonDisabled: isButtonDisabled,
      currentStep: 4,
    );
  }
}
