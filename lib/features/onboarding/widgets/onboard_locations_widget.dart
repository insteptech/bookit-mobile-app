import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/shared/components/organisms/map_selector.dart';
import 'package:bookit_mobile_app/features/onboarding/widgets/onboarding_location_info_form.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardLocationsWidget extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final String? nextButtonText;
  final bool showNextButton;
  final Function(List<Map<String, dynamic>>)? onLocationsChanged;
  final bool showAddButton;
  final List<Map<String, dynamic>>? initialLocations;

  const OnboardLocationsWidget({
    super.key,
    this.onNext,
    this.nextButtonText = "Next: select offering",
    this.showNextButton = true,
    this.onLocationsChanged,
    this.showAddButton = true,
    this.initialLocations,
  });

  @override
  ConsumerState<OnboardLocationsWidget> createState() =>
      _OnboardLocationsWidgetState();
}

class _OnboardLocationsWidgetState extends ConsumerState<OnboardLocationsWidget> {
  List<Map<String, dynamic>> addressControllersList = [];
  bool isFormValid = false;
  bool isOpenMap = false;
  bool isButtonDisabled = false;
  bool isFirstTimeVisit = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
  }

  void _initializeLocations() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<dynamic> locations = [];
      
      if (widget.initialLocations != null) {
        locations = widget.initialLocations!;
      } else {
        final business = ref.read(businessProvider);
        locations = business?.locations ?? [];
        
        if (business == null) {
          final String activeBusinessId = await ActiveBusinessService().getActiveBusiness() as String;
          final businessDetails = await UserService().fetchBusinessDetails(businessId: activeBusinessId);
          locations = businessDetails.locations;
        }
      }

      if (locations.isNotEmpty) {
        for (final loc in locations) {
          _addAddressForm(
            id: loc is Map ? loc['id'] : loc.id,
            location: loc is Map ? loc['title'] : loc.title,
            address: loc is Map ? loc['address'] : loc.address,
            floor: loc is Map ? loc['floor'] : loc.floor,
            city: loc is Map ? loc['city'] : loc.city,
            state: loc is Map ? loc['state'] : loc.state,
            country: loc is Map ? loc['country'] : loc.country,
            instructions: loc is Map ? loc['instructions'] : loc.instructions,
            lat: loc is Map 
                ? (loc['latitude'] as num?)?.toDouble() 
                : loc.latitude?.toDouble(),
            lng: loc is Map 
                ? (loc['longitude'] as num?)?.toDouble() 
                : loc.longitude?.toDouble(),
          );
        }
      } else {
        setState(() {
          isFirstTimeVisit = true;
        });
      }
    } catch (e) {
      print("Error initializing locations: $e");
    } finally {
      setState(() {
        isLoading = false;
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
    bool notifyChanges = true,
  }) {
    final locCtrl = TextEditingController(text: location ?? '');
    final addrCtrl = TextEditingController(text: address ?? '');
    final cityCtrl = TextEditingController(text: city ?? '');
    final stateCtrl = TextEditingController(text: state ?? '');
    final countryCtrl = TextEditingController(text: country ?? '');

    // Listen for changes with debouncing to avoid excessive calls
    void onTextChanged() {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _validateForms();
        }
      });
    }

    [locCtrl, addrCtrl, cityCtrl, stateCtrl, countryCtrl].forEach((ctrl) {
      ctrl.addListener(onTextChanged);
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
      
      if (notifyChanges) {
        _validateForms();
      }
    });
  }

  void _validateForms() {
    bool isValid = addressControllersList.isNotEmpty && addressControllersList.every((form) {
      return (form["location"].text as String).trim().isNotEmpty &&
          (form["address"].text as String).trim().isNotEmpty &&
          (form["city"].text as String).trim().isNotEmpty &&
          (form["state"].text as String).trim().isNotEmpty &&
          (form["country"].text as String).trim().isNotEmpty;
    });

    if (isFormValid != isValid) {
      setState(() {
        isFormValid = isValid;
      });
    }
    
    // Always notify changes so parent can update save button state
    _notifyLocationsChanged();
  }

  void _notifyLocationsChanged() {
    if (widget.onLocationsChanged != null) {
      final locations = addressControllersList.map((controllers) {
        return {
          "id": controllers["id"] ?? "",
          "title": (controllers["location"]?.text ?? "").trim(),
          "address": (controllers["address"]?.text ?? "").trim(),
          "floor": (controllers["floor"]?.text ?? "").trim(),
          "city": (controllers["city"]?.text ?? "").trim(),
          "state": (controllers["state"]?.text ?? "").trim(),
          "country": (controllers["country"]?.text ?? "").trim(),
          "instructions": (controllers["instructions"]?.text ?? "").trim(),
          "latitude": controllers['latitude'] ?? 0.0,
          "longitude": controllers["longitude"] ?? 0.0,
          "is_active": true,
        };
      }).toList();
      widget.onLocationsChanged!(locations);
    }
  }

  Future<void> _submitAddresses() async {
    setState(() {
      isButtonDisabled = true;
    });
    
    final businessId = ref.read(businessProvider)?.id;
    if (businessId == null) {
      setState(() {
        isButtonDisabled = false;
      });
      return;
    }

    final locations = addressControllersList.map((controllers) {
      return {
        "id": controllers["id"] ?? "",
        "title": (controllers["location"]?.text ?? "").trim(),
        "address": (controllers["address"]?.text ?? "").trim(),
        "floor": (controllers["floor"]?.text ?? "").trim(),
        "city": (controllers["city"]?.text ?? "").trim(),
        "state": (controllers["state"]?.text ?? "").trim(),
        "country": (controllers["country"]?.text ?? "").trim(),
        "instructions": (controllers["instructions"]?.text ?? "").trim(),
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
        
        if (widget.onNext != null) {
          widget.onNext!();
        }
      } catch (e) {
        // print("Error fetching business details: $e");
      }
    } catch (e) {
      // print("Error submitting locations: $e");
    } finally {
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  void _removeAddressForm(int index) {
    setState(() {
      final controllers = addressControllersList[index];
      controllers["location"]?.dispose();
      controllers["address"]?.dispose();
      controllers["city"]?.dispose();
      controllers["state"]?.dispose();
      controllers["country"]?.dispose();
      controllers["floor"]?.dispose();
      controllers["instructions"]?.dispose();
      
      addressControllersList.removeAt(index);
      _validateForms();
    });
  }

  void _openMapSelector() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: MapSelector(
            onLocationSelected: (locationData) {
              Navigator.of(context).pop();
              setState(() {
                isFirstTimeVisit = false;
                _addAddressForm(
                  lat: locationData['lat'],
                  lng: locationData['lng'],
                  city: locationData['city'],
                  state: locationData['state'],
                  country: locationData['country'],
                  notifyChanges: false,
                );
              });
              // Notify after a brief delay to ensure form is rendered
              Future.delayed(const Duration(milliseconds: 100), () {
                _notifyLocationsChanged();
              });
            },
            onBackPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        if (addressControllersList.isEmpty && isFirstTimeVisit)
          Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  "No locations added yet",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add your first location to get started",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _openMapSelector,
                  icon: const Icon(Icons.add_location),
                  label: const Text("Add Location"),
                ),
              ],
            ),
          ),
        ...addressControllersList.asMap().entries.map((entry) {
          int index = entry.key;
          var controllers = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: OnboardingLocationInfoForm(
              key: ValueKey(
                "${controllers['latitude']}_${controllers['longitude']}_$index",
              ),
              locationController: controllers["location"]!,
              addressController: controllers["address"]!,
              cityController: controllers["city"]!,
              stateController: controllers["state"]!,
              countryController: controllers["country"]!,
              floorController: controllers["floor"]!,
              instructionController: controllers["instructions"]!,
              // showDeleteButton: addressControllersList.length > 1,
              showDeleteButton: false,
              addressNumber: addressControllersList.length > 1 ? index + 1 : null,
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
                  controllers['country']?.text = updatedLocation['country'] ?? '';
                });
                _notifyLocationsChanged();
              },
            ),
          );
        }),
        if (widget.showAddButton)
          SecondaryButton(
            onPressed: _openMapSelector,
            prefix: Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            text: "Add another address",
          ),
        if (widget.showNextButton) ...[
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isButtonDisabled || !isFormValid ? null : _submitAddresses,
              child: Text(widget.nextButtonText ?? "Next"),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    for (var controllers in addressControllersList) {
      controllers["location"]?.dispose();
      controllers["address"]?.dispose();
      controllers["city"]?.dispose();
      controllers["state"]?.dispose();
      controllers["country"]?.dispose();
      controllers["floor"]?.dispose();
      controllers["instructions"]?.dispose();
    }
    super.dispose();
  }
}