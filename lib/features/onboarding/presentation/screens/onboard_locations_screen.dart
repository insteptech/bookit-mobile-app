import 'package:bookit_mobile_app/features/onboarding/application/application.dart';
import 'package:bookit_mobile_app/shared/components/organisms/map_selector.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/scaffolds/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/widgets/onboarding_location_info_form.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardLocationsScreen extends ConsumerStatefulWidget {
  const OnboardLocationsScreen({super.key});

  @override
  ConsumerState<OnboardLocationsScreen> createState() =>
      _OnboardLocationsScreenState();
}

class _OnboardLocationsScreenState
    extends ConsumerState<OnboardLocationsScreen> {
  
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardLocationsControllerProvider);
    final theme = Theme.of(context);

    if (controller.isOpenMap) {
      return MapSelector(
        onLocationSelected: (locationData) {
          controller.onLocationSelected(locationData);
        },
        onBackPressed: () => controller.handleMapBack(context),
      );
    }

    return OnboardScaffoldLayout(
      heading: "Locations",
      subheading:
          "Tell us where you're located. Go ahead and add your address details below.",
      backButtonDisabled: false,
      body: Column(
        children: [
          ...controller.addressControllersList.asMap().entries.map((entry) {
            int index = entry.key;
            var controllers = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: OnboardingLocationInfoForm(
                key: ValueKey(
                  "${controllers['latitude']}_${controllers['longitude']}",
                ),
                locationController: controllers["location"]!,
                addressController: controllers["address"]!,
                cityController: controllers["city"]!,
                stateController: controllers["state"]!,
                countryController: controllers["country"]!,
                floorController: controllers["floor"]!,
                instructionController: controllers["instructions"]!,
                showDeleteButton: controller.addressControllersList.length > 1,
                addressNumber: controller.addressControllersList.length > 1 ? index + 1 : null,
                lat: controllers['latitude'],
                lng: controllers['longitude'],
                onClick: () {
                  if (controller.addressControllersList.length > 1) {
                    controller.removeAddressForm(index);
                  }
                },
                onLocationUpdated: (updatedLocation) {
                  controller.updateLocationData(index, updatedLocation);
                },
              ),
            );
          }),
          Row(
            children: [
              SecondaryButton(
                onPressed: () {
                  controller.openMap();
                },
                prefix: Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                text: "Add another address",
              ),
            ],
          )
        ],
      ),
      onNext: () async {
        await controller.submitAddresses(context);
      },
      nextButtonText: "Next: select offering",
      nextButtonDisabled: controller.isButtonDisabled || !controller.isFormValid,
      currentStep: 1,
    );
  }
}