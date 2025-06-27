import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/onboarding_api_service.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboarding_location_info_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardLocationsScreen extends ConsumerStatefulWidget {
  final double? lat;
  final double? lng;

  const OnboardLocationsScreen({super.key, this.lat, this.lng});

  @override
  ConsumerState<OnboardLocationsScreen> createState() =>
      _OnboardLocationsScreenState();
}

class _OnboardLocationsScreenState
    extends ConsumerState<OnboardLocationsScreen> {
  List<Map<String, dynamic>> addressControllersList = [];
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();

    final business = ref.read(businessProvider);

    final locations = business?.locations ?? [];

    // print(business);
    // print(locations);

    print("locations: $locations");

    if (locations.isNotEmpty) {
      for (final loc in locations) {
        _addAddressForm(
          id: loc.id,
          location: loc.title,
          address: loc.address,
          floor: loc.floor,
          city: loc.city,
          state: loc.state,
          country: loc.country,
          instructions: loc.instructions,
          lat: loc.latitude?.toDouble(),
          lng: loc.longitude?.toDouble(),
        );
      }
    } else {
      _addAddressForm(lat: widget.lat, lng: widget.lng);
    }
  }

  void _addAddressForm({
  String? id,
  String? location,
  String? address,
  String? floor,
  String? city,
  String? state,
  String? country,
  String? instructions,
  double? lat,
  double? lng,
}) {
  final locCtrl = TextEditingController(text: location ?? '');
  final addrCtrl = TextEditingController(text: address ?? '');
  final cityCtrl = TextEditingController(text: city ?? '');
  final stateCtrl = TextEditingController(text: state ?? '');
  final countryCtrl = TextEditingController(text: country ?? '');

  // Listen for changes
  [locCtrl, addrCtrl, cityCtrl, stateCtrl, countryCtrl].forEach((ctrl) {
    ctrl.addListener(_validateForms);
  });

  setState(() {
    addressControllersList.add({
      "id": id,
      "location": locCtrl,
      "address": addrCtrl,
      "floor": TextEditingController(text: floor ?? ''),
      "city": cityCtrl,
      "state": stateCtrl,
      "country": countryCtrl,
      "instructions": TextEditingController(text: instructions ?? ''),
      "latitude": lat ?? 0.0,
      "longitude": lng ?? 0.0,
    });
    _validateForms();
  });
}


  void _validateForms() {
  bool isValid = addressControllersList.every((form) {
    return form["location"].text.isNotEmpty &&
        form["address"].text.isNotEmpty &&
        form["city"].text.isNotEmpty &&
        form["state"].text.isNotEmpty &&
        form["country"].text.isNotEmpty;
  });

  if (isFormValid != isValid) {
    setState(() {
      isFormValid = isValid;
    });
  }
}


  Future<void> _submitAddresses() async {
    final businessId = ref.read(businessProvider)?.id;

    if (businessId == null) {
      return;
    }

    final locations =
        addressControllersList.map((controllers) {
          return {
            "id": controllers["id"] ?? "",
            "title": controllers["location"]?.text ?? "",
            "address": controllers["address"]?.text ?? "",
            "floor": controllers["floor"]?.text ?? "",
            "city": controllers["city"]?.text ?? "",
            "state": controllers["state"]?.text ?? "",
            "country": controllers["country"]?.text ?? "",
            "instructions": controllers["instructions"]?.text ?? "",
            "latitude": 233,
            "longitude": 332,
            "is_active": true,
          };
        }).toList();


    try {
      await OnboardingApiService().submitLocationInfo(
        businessId: businessId,
        locations: locations,
      );
      try {
        final businessDetails = await UserService().fetchBusinessDetails(
          businessId: businessId,
        );
        ref.read(businessProvider.notifier).state = businessDetails;
        
        context.go("/offerings");
      } catch (e) {
        print("Error fething business details: $e");
      }
    } catch (e) {
      print("Error submitting locations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardScaffoldLayout(
      heading: "Locations",
      subheading:
          "Tell us where you're located. Go ahead and add your address details below.",
      body: Column(
        children: [
          ...addressControllersList.map((controllers) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: OnboardingLocationInfoForm(
                locationController: controllers["location"]!,
                addressController: controllers["address"]!,
                cityController: controllers["city"]!,
                stateController: controllers["state"]!,
                countryController: controllers["country"]!,
                floorController: controllers["floor"]!,
                instructionController: controllers["instructions"]!,
              ),
            );
          }),
          GestureDetector(
            onTap: _addAddressForm,
            child: Row(
              children: [
                Icon(Icons.add, color: theme.colorScheme.primary),
                SizedBox(width: 8),
                Text(
                  "Add another address",
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onNext: () async {
        await _submitAddresses();
        // context.push("/offerings");
      },
      nextButtonText: "Next: select offering",
      nextButtonDisabled: false,
      currentStep: 1,
    );
  }
}
