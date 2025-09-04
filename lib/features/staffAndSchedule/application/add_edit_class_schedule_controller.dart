import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';

class AddEditClassScheduleController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  
  Map<String, dynamic>? _serviceData;
  Map<String, dynamic>? _existingClassData;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _allStaffMembers = [];
  String? _businessId;
  
  // Image handling
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Class details form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController packagePersonController = TextEditingController();
  final TextEditingController packageAmountController = TextEditingController();
  
  // Class schedule data - organized by location
  final Map<String, List<Map<String, dynamic>>> _schedulesByLocation = {};
  final Map<String, bool> _spotsLimitEnabledByLocation = {};
  final Map<String, TextEditingController> _spotsControllersByLocation = {};
  final Map<String, bool> _classAvailabilityByLocation = {};
  final Map<String, Map<String, dynamic>> _locationPricingData = {};
  
  bool _spotsLimitEnabled = false;
  final TextEditingController spotsController = TextEditingController();

  // Constructor
  AddEditClassScheduleController() {
    // Add listeners to text controllers to notify when text changes
    titleController.addListener(() => notifyListeners());
    descriptionController.addListener(() => notifyListeners());
    durationController.addListener(() => notifyListeners());
    priceController.addListener(() => notifyListeners());
    packagePersonController.addListener(() => notifyListeners());
    packageAmountController.addListener(() => notifyListeners());
    spotsController.addListener(() => notifyListeners());
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get serviceData => _serviceData;
  Map<String, dynamic>? get existingClassData => _existingClassData;
  File? get selectedImage => _selectedImage;
  List<Map<String, dynamic>> get locations => _locations;
  List<Map<String, dynamic>> get allStaffMembers => _allStaffMembers;
  String? get businessId => _businessId;
  Map<String, List<Map<String, dynamic>>> get schedulesByLocation => _schedulesByLocation;
  Map<String, bool> get spotsLimitEnabledByLocation => _spotsLimitEnabledByLocation;
  Map<String, TextEditingController> get spotsControllersByLocation => _spotsControllersByLocation;
  Map<String, bool> get classAvailabilityByLocation => _classAvailabilityByLocation;
  bool get spotsLimitEnabled => _spotsLimitEnabled;
  Map<String, Map<String, dynamic>> get locationPricingData => _locationPricingData;

  void setSpotsLimitEnabled(bool enabled) {
    _spotsLimitEnabled = enabled;
    if (!enabled) {
      spotsController.clear();
    }
    notifyListeners();
  }

  void setLocationSpotsLimitEnabled(String locationId, bool enabled) {
    _spotsLimitEnabledByLocation[locationId] = enabled;
    if (!enabled) {
      _spotsControllersByLocation[locationId]?.clear();
    }
    notifyListeners();
  }

  void setLocationClassAvailability(String locationId, bool available) {
    _classAvailabilityByLocation[locationId] = available;
    if (!available) {
      // Clear schedules when class availability is disabled
      _schedulesByLocation[locationId] = [];
    }
    notifyListeners();
  }

  TextEditingController getLocationSpotsController(String locationId) {
    if (!_spotsControllersByLocation.containsKey(locationId)) {
      _spotsControllersByLocation[locationId] = TextEditingController();
    }
    return _spotsControllersByLocation[locationId]!;
  }

  Future<void> initialize({
    Map<String, dynamic>? serviceData,
    String? classId,
    bool isEditing = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchBusinessId();
      await Future.wait([
        _fetchLocations(),
        _fetchStaffMembers(),
      ]);

      _serviceData = serviceData;

      if (isEditing && classId != null) {
        await _fetchExistingClassData(classId);
        _prefillFormData();
      } else if (serviceData != null) {
        _prefillFromServiceData(serviceData);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchBusinessId() async {
    try {
      final businessId = await ActiveBusinessService().getActiveBusiness();
      if (businessId == null) {
        throw Exception('No active business found');
      }
      _businessId = businessId.toString();
    } catch (e) {
      throw Exception('Failed to fetch business ID: $e');
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await APIRepository.getBusinessLocations();
      final rows = response['rows'] as List<dynamic>?;
      if (rows == null) {
        _locations = [];
        return;
      }
      
      _locations = rows
          .map((loc) => {
                'id': (loc['id'] ?? '').toString(),
                'title': (loc['title'] ?? '').toString(),
                'location_id': (loc['id'] ?? '').toString(),
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<void> _fetchStaffMembers() async {
    try {
      final response = await APIRepository.getStaffListByBusinessId();
      final profiles = response.data?['data']?['profiles'] as List<dynamic>?;
      if (profiles == null) {
        _allStaffMembers = [];
        return;
      }
      
      // Filter staff members who are available for classes (for_class: true)
      _allStaffMembers = profiles
          .cast<Map<String, dynamic>>()
          .where((staff) => staff['for_class'] == true)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch staff members: $e');
    }
  }

  Future<void> _fetchExistingClassData(String classId) async {
    try {
      final response = await APIRepository.getClassAndSchedule(classId);
      if (response.data != null && response.data['data'] != null) {
        _existingClassData = response.data['data']['data'];
      }
    } catch (e) {
      throw Exception('Failed to fetch class data: $e');
    }
  }

  void _prefillFromServiceData(Map<String, dynamic> serviceData) {
    // Keep title controller empty so user can enter custom class title
    titleController.text = '';
    descriptionController.text = serviceData['description'] ?? '';
    
    // Initialize empty schedules for all locations
    for (var location in _locations) {
      final locationId = location['id'];
      _schedulesByLocation[locationId] = [];
      _spotsLimitEnabledByLocation[locationId] = false;
      _classAvailabilityByLocation[locationId] = false; // Default to false
    }
  }

  void _prefillFormData() {
    if (_existingClassData == null) return;

    final data = _existingClassData!;
    
    // Fill class details from the new API response structure
    titleController.text = data['name'] ?? '';
    descriptionController.text = data['description'] ?? '';
    
    // Fill duration and pricing from durations array
    if (data['durations'] != null && data['durations'].isNotEmpty) {
      final duration = data['durations'][0];
      durationController.text = duration['duration_minutes']?.toString() ?? '';
      priceController.text = duration['price']?.toString() ?? '';
      packagePersonController.text = duration['package_person']?.toString() ?? '';
      packageAmountController.text = duration['package_amount']?.toString() ?? '';
    }

    // Initialize schedules for all locations
    _schedulesByLocation.clear();
    _classAvailabilityByLocation.clear();
    for (var location in _locations) {
      final locationId = location['id'];
      _schedulesByLocation[locationId] = [];
      _classAvailabilityByLocation[locationId] = false;
    }

    // Organize schedules by location from the new API response structure
    if (data['schedules'] != null) {
      for (var schedule in data['schedules']) {
        final locationId = schedule['location']?['id']?.toString();
        if (locationId != null && locationId.isNotEmpty && _schedulesByLocation.containsKey(locationId)) {
          // Enable class availability for locations that have schedules
          _classAvailabilityByLocation[locationId] = true;
          
          _schedulesByLocation[locationId]!.add({
            'id': schedule['id'],
            'day': schedule['day_of_week'],
            'start_time': schedule['start_time'],
            'end_time': schedule['end_time'],
            'instructor_ids': (schedule['instructors'] as List<dynamic>?)
                ?.map((i) => i['id']?.toString())
                .where((id) => id != null && id.isNotEmpty)
                .toList() ?? [],
            'instructor_names': (schedule['instructors'] as List<dynamic>?)
                ?.map((i) => i['name']?.toString())
                .where((name) => name != null && name.isNotEmpty)
                .toList() ?? [],
            'spots_available': schedule['spots_available'],
          });
        }
      }
    }
  }

  void updateLocationSchedule(String locationId, List<Map<String, dynamic>> schedules) {
    _schedulesByLocation[locationId] = schedules;
    notifyListeners();
  }

  void updateLocationPricing(String locationId, bool enabled, double? price, int? packagePerson, double? packageAmount) {
    _locationPricingData[locationId] = {
      'enabled': enabled,
      'price': price,
      'packagePerson': packagePerson,
      'packageAmount': packageAmount,
    };
    notifyListeners();
  }

  List<Map<String, dynamic>> getStaffForLocation(String locationId) {
    // Return all staff members since one user can be available at multiple locations
    return _allStaffMembers;
  }

  bool get canSubmit {
    return titleController.text.trim().isNotEmpty &&
           durationController.text.trim().isNotEmpty &&
           priceController.text.trim().isNotEmpty &&
           _businessId != null &&
           _hasValidScheduleConfiguration();
  }

  bool get canProceedToSchedule {
    return titleController.text.trim().isNotEmpty &&
           durationController.text.trim().isNotEmpty &&
           priceController.text.trim().isNotEmpty &&
           _businessId != null;
  }

  bool _hasValidScheduleConfiguration() {
    // Allow saving even if all class availability is false (no schedules required)
    // But if any location has class availability enabled, it must have complete schedules
    for (var entry in _schedulesByLocation.entries) {
      final locationId = entry.key;
      final isAvailable = _classAvailabilityByLocation[locationId] ?? false;
      
      // If class availability is enabled for this location, it must have complete schedules
      if (isAvailable && !_hasCompleteScheduleForLocation(locationId)) {
        return false;
      }
    }
    
    // All enabled locations have valid schedules (or no locations are enabled)
    return true;
  }

  bool _hasCompleteScheduleForLocation(String locationId) {
    final schedules = _schedulesByLocation[locationId] ?? [];
    return schedules.isNotEmpty && 
           schedules.every((schedule) => 
             schedule['day'] != null && 
             schedule['start_time'] != null && 
             schedule['end_time'] != null &&
             schedule['instructor_ids'] != null &&
             (schedule['instructor_ids'] as List).isNotEmpty
           );
  }

  Future<bool> saveClassAndSchedule() async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _buildSavePayload();
      
      // Debug logging - remove in production
      // final isUpdate = _existingClassData != null;
      // print('=== ${isUpdate ? 'UPDATE' : 'NEW SAVE'} CLASS PAYLOAD ===');
      // print('Form Data:');
      // print('  Title: "${titleController.text}"');
      // print('  Description: "${descriptionController.text}"');
      // print('  Description.trim(): "${descriptionController.text.trim()}"');
      // print('  Duration: "${durationController.text}"');
      // print('  Price: "${priceController.text}"');
      // print('Payload: ${payload.toString()}');
      // print('=======================================');
      
      // Call the API with image support
      final response = await APIRepository.saveClassAndScheduleWithImage(
        payload: [payload], 
        image: _selectedImage
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> _buildSavePayload() {
    // Debug logging - remove in production
    // print('Building payload - description value: "${descriptionController.text.trim()}"');
    
    final serviceDetail = {
      'business_id': _businessId,
      'is_class': true,
      'is_archived': false,
      'tags': [],
      'media_url': '',
      'limit_on_spots': _spotsLimitEnabled,
      'spot_limit': _spotsLimitEnabled ? int.tryParse(spotsController.text.trim()) : null,
      'durations': [
        {
          'duration_minutes': int.tryParse(durationController.text.trim()) ?? 0,
          'price': double.tryParse(priceController.text.trim()) ?? 0.0,
          if (packagePersonController.text.trim().isNotEmpty)
            'package_person': int.tryParse(packagePersonController.text.trim()),
          if (packageAmountController.text.trim().isNotEmpty)
            'package_amount': double.tryParse(packageAmountController.text.trim()),
        }
      ],
      if (_serviceData != null) ..._serviceData!,
      // Add form values AFTER serviceData to ensure they take precedence
      'name': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      // Add id and category_id when updating
      if (_existingClassData != null) 'id': _existingClassData!['id'],
      if (_existingClassData != null && _existingClassData!['category_id'] != null) 
        'category_id': _existingClassData!['category_id'],
    };
    
    // Debug logging - remove in production
    // print('ServiceDetail after building: ${serviceDetail.toString()}');
    // print('_serviceData: ${_serviceData.toString()}');

    // Build location schedules
    final List<Map<String, dynamic>> locationSchedules = [];
    
    for (var entry in _schedulesByLocation.entries) {
      final locationId = entry.key;
      final schedules = entry.value;
      final isAvailable = _classAvailabilityByLocation[locationId] ?? false;
      
      // Only include locations where class availability is enabled and has schedules
      if (isAvailable && schedules.isNotEmpty) {
        final locationSchedule = <String, dynamic>{
          'location_id': locationId,
          'class_available': true,
          'schedules': schedules.map((schedule) => {
            'day_of_week': schedule['day'],
            'start_time': schedule['start_time'],
            'end_time': schedule['end_time'],
            'instructor_ids': schedule['instructor_ids'] ?? [],
            if (schedule['spots_available'] != null) 
              'spots_available': schedule['spots_available'],
            // Include schedule ID when updating
            if (schedule['id'] != null) 'id': schedule['id'],
          }).toList(),
        };

        // Add location-specific pricing if enabled
        final pricingData = _locationPricingData[locationId];
        if (pricingData != null && pricingData['enabled'] == true) {
          if (pricingData['price'] != null) {
            locationSchedule['price_override'] = pricingData['price'];
          }
          if (pricingData['packagePerson'] != null) {
            locationSchedule['package_person_override'] = pricingData['packagePerson'];
          }
          if (pricingData['packageAmount'] != null) {
            locationSchedule['package_amount_override'] = pricingData['packageAmount'];
          }
        }

        locationSchedules.add(locationSchedule);
      }
    }

    return {
      'service_detail': serviceDetail,
      'location_schedules': locationSchedules,
      if (_existingClassData != null) 
        'class_id': _existingClassData!['id'] ?? _existingClassData!['class_id'],
    };
  }

  // Image handling methods
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress to reduce file size
        maxWidth: 800,   // Limit max width
        maxHeight: 800,  // Limit max height
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      // Debug logging - remove in production
      // debugPrint('Error picking image: $e');
      // Could add error handling here if needed
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      // Debug logging - remove in production
      // debugPrint('Error taking photo: $e');
    }
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    titleController.removeListener(() => notifyListeners());
    descriptionController.removeListener(() => notifyListeners());
    durationController.removeListener(() => notifyListeners());
    priceController.removeListener(() => notifyListeners());
    packagePersonController.removeListener(() => notifyListeners());
    packageAmountController.removeListener(() => notifyListeners());
    spotsController.removeListener(() => notifyListeners());
    
    // Dispose controllers
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    priceController.dispose();
    packagePersonController.dispose();
    packageAmountController.dispose();
    spotsController.dispose();
    
    for (var controller in _spotsControllersByLocation.values) {
      controller.dispose();
    }
    
    super.dispose();
  }
}