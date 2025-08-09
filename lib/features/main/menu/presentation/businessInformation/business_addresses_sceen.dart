import 'package:bookit_mobile_app/features/main/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/features/onboarding/presentation/widgets/onboard_locations_widget.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/onboarding_api_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessAddressesScreen extends ConsumerStatefulWidget {
  const BusinessAddressesScreen({super.key});

  @override
  ConsumerState<BusinessAddressesScreen> createState() => _BusinessAddressesScreenState();
}

class _BusinessAddressesScreenState extends ConsumerState<BusinessAddressesScreen> {
  List<Map<String, dynamic>> currentLocations = [];
  bool isSaving = false;
  bool hasChanges = false;
  bool isFormValid = false;

  @override
  Widget build(BuildContext context) {
    // Calculate if button should be disabled
    bool isButtonDisabled = !hasChanges || 
                           isSaving || 
                           currentLocations.isEmpty || 
                           !isFormValid;

    return MenuScreenScaffold(
      title: "Addresses", 
      content: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: OnboardLocationsWidget(
                showNextButton: false,
                onLocationsChanged: (locations) {
                  setState(() {
                    currentLocations = locations;
                    hasChanges = true;
                    // Validate all locations have required fields filled
                    isFormValid = _validateAllLocations(locations);
                  });
                },
              ),
            ),
          ),
        ],
      ),
      buttonText: isSaving ? "Saving..." : "Save changes",
      // Always provide the callback, but use isButtonDisabled to control the state
      onButtonPressed: _saveLocations,
      isButtonDisabled: isButtonDisabled,
    );
  }

  // Add validation method for all locations
  bool _validateAllLocations(List<Map<String, dynamic>> locations) {
    if (locations.isEmpty) return false;
    
    return locations.every((location) {
      return (location["title"] as String? ?? "").trim().isNotEmpty &&
             (location["address"] as String? ?? "").trim().isNotEmpty &&
             (location["city"] as String? ?? "").trim().isNotEmpty &&
             (location["state"] as String? ?? "").trim().isNotEmpty &&
             (location["country"] as String? ?? "").trim().isNotEmpty;
    });
  }

  Future<void> _saveLocations() async {
    // Early return if button should be disabled (extra safety check)
    if (!hasChanges || isSaving || currentLocations.isEmpty || !isFormValid) {
      return;
    }

    // Double check validation before saving
    if (!_validateAllLocations(currentLocations)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields for each location'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Get business ID
      final String businessId = await ActiveBusinessService().getActiveBusiness() as String;
      if (businessId.isEmpty) {
        throw Exception('No business ID found');
      }

      // Submit locations
      await OnboardingApiService().submitLocationInfo(
        businessId: businessId,
        locations: currentLocations,
      );

      // Refresh business data
      final businessDetails = await UserService().fetchBusinessDetails(
        businessId: businessId,
      );
      ref.read(businessProvider.notifier).state = businessDetails;
      
      setState(() {
        hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Addresses saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving addresses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }
}