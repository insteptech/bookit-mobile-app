import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/auth_service.dart';
import 'package:bookit_mobile_app/core/services/onboarding_api_service.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/shared/components/organisms/map_selector.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboarding_location_info_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardLocationsScreen extends ConsumerStatefulWidget {
  const OnboardLocationsScreen({super.key});

  @override
  ConsumerState<OnboardLocationsScreen> createState() =>
      _OnboardLocationsScreenState();
}

class _OnboardLocationsScreenState
    extends ConsumerState<OnboardLocationsScreen> {
  List<Map<String, dynamic>> addressControllersList = [];
  bool isFormValid = false;
  bool isOpenMap = false;

  @override
  void initState() {
    super.initState();

    final business = ref.read(businessProvider);

    final locations = business?.locations ?? [];

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
      // _addAddressForm(lat: widget.lat, lng: widget.lng);
      setState(() {
        isOpenMap = true;
      });
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
            "latitude": controllers['latitude'] ?? 0.0,
            "longitude": controllers["longitude"] ?? 0.0,
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

        context.push("/offerings");
      } catch (e) {
        print("Error fething business details: $e");
      }
    } catch (e) {
      print("Error submitting locations: $e");
    } finally {}
  }

  void _removeAddressForm(int index) {
    setState(() {
      addressControllersList.removeAt(index);
      _validateForms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOpenMap) {
      return MapSelector(
        onLocationSelected: (locationData) {
          setState(() {
            isOpenMap = false;
            _addAddressForm(
              lat: locationData['lat'],
              lng: locationData['lng'],
              city: locationData['city'],
              state: locationData['state'],
              country: locationData['country'],
            );
          });
        },
      );
    }

    return OnboardScaffoldLayout(
      heading: "Locations",
      subheading:
          "Tell us where you're located. Go ahead and add your address details below.",
      body: Column(
        children: [
          ...addressControllersList.asMap().entries.map((entry) {
            int index = entry.key;
            var controllers = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: OnboardingLocationInfoForm(
                key: ValueKey(
                  "${controllers['latitude']}_${controllers['longitude']}",
                ), // 👈 forces rebuild,
                locationController: controllers["location"]!,
                addressController: controllers["address"]!,
                cityController: controllers["city"]!,
                stateController: controllers["state"]!,
                countryController: controllers["country"]!,
                floorController: controllers["floor"]!,
                instructionController: controllers["instructions"]!,
                showDeleteButton: addressControllersList.length > 1,
                lat: controllers['latitude'],
                lng: controllers['longitude'],
                onClick: () {
                  if (addressControllersList.length > 1) {
                    _removeAddressForm(index);
                  }
                },
                onLocationUpdated: (updatedLocation) {
                  setState(() {
                    controllers['latitude'] = updatedLocation['lat'];
                    controllers['longitude'] = updatedLocation['lng'];
                    controllers['city']?.text = updatedLocation['city'] ?? '';
                    controllers['state']?.text = updatedLocation['state'] ?? '';
                    controllers['country']?.text =
                        updatedLocation['country'] ?? '';
                  });
                },
              ),
            );
          }),
          GestureDetector(
            onTap: () {
              setState(() {
                isOpenMap = true;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 5),
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