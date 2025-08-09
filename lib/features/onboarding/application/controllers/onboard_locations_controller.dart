import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/features/onboarding/data/data.dart';
import 'package:bookit_mobile_app/features/onboarding/application/providers.dart';

class OnboardLocationsController extends ChangeNotifier {
  final Ref ref;
  late final OnboardingRepository _repository;

  // State
  final List<Map<String, dynamic>> _addressControllersList = [];
  bool _isFormValid = false;
  bool _isOpenMap = false;
  bool _isButtonDisabled = false;
  bool _isFirstTimeVisit = false;
  String? _errorMessage;

  // Services
  final UserService _userService = UserService();

  OnboardLocationsController(this.ref) {
    _repository = ref.read(onboardingRepositoryProvider);
    _initializeFromBusiness();
  }

  // Getters
  List<Map<String, dynamic>> get addressControllersList => _addressControllersList;
  bool get isFormValid => _isFormValid;
  bool get isOpenMap => _isOpenMap;
  bool get isButtonDisabled => _isButtonDisabled;
  bool get isFirstTimeVisit => _isFirstTimeVisit;
  String? get errorMessage => _errorMessage;

  void _initializeFromBusiness() {
    final business = ref.read(businessProvider);
    final locations = business?.locations ?? [];

    if (locations.isNotEmpty) {
      // User has existing locations, populate forms
      for (final loc in locations) {
        addAddressForm(
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
      // First time visit - no existing locations
      _isOpenMap = true;
      _isFirstTimeVisit = true;
      notifyListeners();
    }
  }

  void addAddressForm({
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
    for (final ctrl in [locCtrl, addrCtrl, cityCtrl, stateCtrl, countryCtrl]) {
      ctrl.addListener(_validateForms);
    }

    _addressControllersList.add({
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
    notifyListeners();
  }

  void _validateForms() {
    bool isValid = _addressControllersList.every((form) {
      return form["location"].text.isNotEmpty &&
          form["address"].text.isNotEmpty &&
          form["city"].text.isNotEmpty &&
          form["state"].text.isNotEmpty &&
          form["country"].text.isNotEmpty;
    });

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }
  }

  Future<void> submitAddresses(BuildContext context) async {
    _isButtonDisabled = true;
    _errorMessage = null;
    notifyListeners();

    final businessId = ref.read(businessProvider)?.id;

    if (businessId == null) {
      _isButtonDisabled = false;
      _errorMessage = "Business ID not found";
      notifyListeners();
      return;
    }

    final locations = _addressControllersList.map((controllers) {
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
      await _repository.submitLocationInfo(
        businessId: businessId,
        locations: locations,
      );
      
      try {
        final businessDetails = await _userService.fetchBusinessDetails(
          businessId: businessId,
        );
        ref.read(businessProvider.notifier).state = businessDetails;
        
        if (context.mounted) {
          context.push("/offerings");
        }
      } catch (e) {
        _errorMessage = "Error fetching business details: $e";
      }
    } catch (e) {
      _errorMessage = "Error submitting locations: $e";
    } finally {
      _isButtonDisabled = false;
      notifyListeners();
    }
  }

  void removeAddressForm(int index) {
    if (index < _addressControllersList.length) {
      // Dispose controllers to prevent memory leaks
      final controllers = _addressControllersList[index];
      controllers["location"]?.dispose();
      controllers["address"]?.dispose();
      controllers["floor"]?.dispose();
      controllers["city"]?.dispose();
      controllers["state"]?.dispose();
      controllers["country"]?.dispose();
      controllers["instructions"]?.dispose();

      _addressControllersList.removeAt(index);
      _validateForms();
      notifyListeners();
    }
  }

  void handleMapBack(BuildContext context) {
    if (_isFirstTimeVisit && _addressControllersList.isEmpty) {
      // First time visit with no locations added yet - go back to previous screen
      if (context.mounted) {
        context.pop();
      }
    } else {
      // Close the map and return to form view
      _isOpenMap = false;
      notifyListeners();
    }
  }

  void openMap() {
    _isOpenMap = true;
    notifyListeners();
  }

  void onLocationSelected(Map<String, dynamic> locationData) {
    _isOpenMap = false;
    _isFirstTimeVisit = false; // No longer first time after adding location
    
    addAddressForm(
      lat: locationData['lat'],
      lng: locationData['lng'],
      city: locationData['city'],
      state: locationData['state'],
      country: locationData['country'],
    );
  }

  void updateLocationData(int index, Map<String, dynamic> updatedLocation) {
    if (index < _addressControllersList.length) {
      final controllers = _addressControllersList[index];
      controllers['latitude'] = updatedLocation['lat'];
      controllers['longitude'] = updatedLocation['lng'];
      controllers['city']?.text = updatedLocation['city'] ?? '';
      controllers['state']?.text = updatedLocation['state'] ?? '';
      controllers['country']?.text = updatedLocation['country'] ?? '';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (final controllers in _addressControllersList) {
      controllers["location"]?.dispose();
      controllers["address"]?.dispose();
      controllers["floor"]?.dispose();
      controllers["city"]?.dispose();
      controllers["state"]?.dispose();
      controllers["country"]?.dispose();
      controllers["instructions"]?.dispose();
    }
    super.dispose();
  }
}
