import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';

class DurationData {
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController packagePersonController = TextEditingController();
  final TextEditingController packageAmountController = TextEditingController();
  String? id; // For existing durations

  DurationData({this.id});

  void dispose() {
    durationController.dispose();
    priceController.dispose();
    packagePersonController.dispose();
    packageAmountController.dispose();
  }
}

class EditOfferingsController extends ChangeNotifier {
  
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController spotsController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isClass = false;
  bool _spotsLimitEnabled = false;
  String? _serviceDetailId;
  
  // Duration and pricing data
  List<DurationData> _durations = [DurationData()];
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isClass => _isClass;
  bool get spotsLimitEnabled => _spotsLimitEnabled;
  List<DurationData> get durations => _durations;

  void setSpotsLimitEnabled(bool value) {
    _spotsLimitEnabled = value;
    notifyListeners();
  }

  void addDuration() {
    _durations.add(DurationData());
    notifyListeners();
  }

  void removeDuration(int index) {
    if (_durations.length > 1) {
      _durations[index].dispose();
      _durations.removeAt(index);
      notifyListeners();
    }
  }

  void updateDuration(int index, String value) {
    if (index < _durations.length) {
      // If duration is cleared, clear related cost fields
      if (value.isEmpty) {
        _durations[index].priceController.clear();
        _durations[index].packageAmountController.clear();
        _durations[index].packagePersonController.clear();
      }
      notifyListeners();
    }
  }

  void updatePrice(int index, String value) {
    // Just trigger rebuild, value is already in the controller
    notifyListeners();
  }

  void updatePackagePerson(int index, String value) {
    // Just trigger rebuild, value is already in the controller
    notifyListeners();
  }

  void updatePackageAmount(int index, String value) {
    // Just trigger rebuild, value is already in the controller
    notifyListeners();
  }

  Future<void> fetchServiceDetails(String serviceDetailId) async {
    _isLoading = true;
    _errorMessage = null;
    _serviceDetailId = serviceDetailId;
    notifyListeners();

    try {
      final response = await APIRepository.getServiceDetailsById(serviceDetailId);
      
      if (response['success'] == true && response['data'] != null) {
        final serviceData = response['data']['service_detail'];
        final businessService = serviceData['business_service'];
        
        // Populate basic info
        _isClass = businessService['is_class'] ?? false;
        
        titleController.text = serviceData['name'] ?? '';
        descriptionController.text = serviceData['description'] ?? '';
        
        // Populate durations
        final durationsData = serviceData['durations'] as List<dynamic>? ?? [];
        _durations.clear();
        
        if (durationsData.isNotEmpty) {
          for (final durationData in durationsData) {
            final duration = DurationData(id: durationData['id']);
            duration.durationController.text = durationData['duration_minutes']?.toString() ?? '';
            duration.priceController.text = durationData['price']?.toString() ?? '';
            duration.packagePersonController.text = durationData['package_person']?.toString() ?? '';
            duration.packageAmountController.text = durationData['package_amount']?.toString() ?? '';
            _durations.add(duration);
          }
        } else {
          _durations.add(DurationData());
        }
        
        // Set spots limit (you can add this field to your API response)
        _spotsLimitEnabled = false; // Default for now
        spotsController.text = '14'; // Default from the image
        
      } else {
        _errorMessage = 'Failed to load service details';
      }
    } catch (e) {
      _errorMessage = 'Error loading service details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveChanges() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate required fields
      if (titleController.text.trim().isEmpty) {
        _errorMessage = 'Title is required';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Prepare durations data
      final validDurations = _durations.where((duration) {
        return duration.durationController.text.isNotEmpty &&
               duration.priceController.text.isNotEmpty;
      }).map((duration) {
        final durationData = <String, dynamic>{
          'duration_minutes': int.tryParse(duration.durationController.text) ?? 0,
          'price': double.tryParse(duration.priceController.text) ?? 0.0,
        };
        
        if (duration.packagePersonController.text.isNotEmpty) {
          durationData['package_person'] = int.tryParse(duration.packagePersonController.text) ?? 0;
        }
        
        if (duration.packageAmountController.text.isNotEmpty) {
          durationData['package_amount'] = double.tryParse(duration.packageAmountController.text) ?? 0.0;
        }
        
        // Include ID for existing durations
        if (duration.id != null) {
          durationData['id'] = duration.id!;
        }
        
        return durationData;
      }).toList();

      if (validDurations.isEmpty) {
        _errorMessage = 'At least one duration and price is required';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Prepare payload
      final payload = {
        'name': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'durations': validDurations,
      };

      

      // Add spots_available if enabled (for classes)
      if (_isClass && _spotsLimitEnabled && spotsController.text.isNotEmpty) {
        payload['spots_available'] = int.tryParse(spotsController.text) ?? 0;
      }

      // API call to update service details
      final response = await APIRepository.updateServiceDetails(_serviceDetailId!, payload);
      
      if (response['success'] == true) {
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to save changes';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
      // return false;
    } catch (e) {
      _errorMessage = 'Error saving changes: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    spotsController.dispose();
    for (final duration in _durations) {
      duration.dispose();
    }
    super.dispose();
  }
}
