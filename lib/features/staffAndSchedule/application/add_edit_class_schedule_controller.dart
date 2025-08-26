import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> get locations => _locations;
  List<Map<String, dynamic>> get allStaffMembers => _allStaffMembers;
  String? get businessId => _businessId;
  Map<String, List<Map<String, dynamic>>> get schedulesByLocation => _schedulesByLocation;
  Map<String, bool> get spotsLimitEnabledByLocation => _spotsLimitEnabledByLocation;
  Map<String, TextEditingController> get spotsControllersByLocation => _spotsControllersByLocation;
  Map<String, bool> get classAvailabilityByLocation => _classAvailabilityByLocation;
  bool get spotsLimitEnabled => _spotsLimitEnabled;

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
      _businessId = await ActiveBusinessService().getActiveBusiness() as String;
    } catch (e) {
      throw Exception('Failed to fetch business ID: $e');
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final response = await APIRepository.getBusinessLocations();
      _locations = (response['rows'] as List<dynamic>)
          .map((loc) => {
                'id': loc['id'].toString(),
                'title': loc['title'].toString(),
                'location_id': loc['id'].toString(),
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch locations: $e');
    }
  }

  Future<void> _fetchStaffMembers() async {
    try {
      final response = await APIRepository.getStaffListByBusinessId();
      _allStaffMembers = (response.data['data']['profiles'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch staff members: $e');
    }
  }

  Future<void> _fetchExistingClassData(String classId) async {
    try {
      final response = await APIRepository.getClassDetails(classId);
      if (response['data'] != null) {
        _existingClassData = response['data']['data'];
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
    
    // Fill class details
    if (data['service_details'] != null && data['service_details'].isNotEmpty) {
      final serviceDetail = data['service_details'][0];
      titleController.text = serviceDetail['name'] ?? '';
      descriptionController.text = serviceDetail['description'] ?? '';
      
      if (serviceDetail['durations'] != null && serviceDetail['durations'].isNotEmpty) {
        final duration = serviceDetail['durations'][0];
        durationController.text = duration['duration_minutes']?.toString() ?? '';
        priceController.text = duration['price']?.toString() ?? '';
        packagePersonController.text = duration['package_person']?.toString() ?? '';
        packageAmountController.text = duration['package_amount']?.toString() ?? '';
      }
    }

    // Organize schedules by location
    if (data['schedules'] != null) {
      _schedulesByLocation.clear();
      for (var location in _locations) {
        _schedulesByLocation[location['id']] = [];
      }

      for (var schedule in data['schedules']) {
        final locationId = schedule['location']?['id'];
        if (locationId != null && _schedulesByLocation.containsKey(locationId)) {
          _schedulesByLocation[locationId]!.add({
            'id': schedule['id'],
            'day': schedule['day_of_week'],
            'start_time': schedule['start_time'],
            'end_time': schedule['end_time'],
            'instructor_ids': (schedule['instructors'] as List<dynamic>?)
                ?.map((i) => i['id']?.toString())
                .where((id) => id != null)
                .toList() ?? [],
            'instructor_names': (schedule['instructors'] as List<dynamic>?)
                ?.map((i) => i['name']?.toString())
                .where((name) => name != null)
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

  List<Map<String, dynamic>> getStaffForLocation(String locationId) {
    // Return all staff members since one user can be available at multiple locations
    return _allStaffMembers;
  }

  bool get canSubmit {
    return titleController.text.trim().isNotEmpty &&
           durationController.text.trim().isNotEmpty &&
           priceController.text.trim().isNotEmpty &&
           _businessId != null &&
           _hasAtLeastOneSchedule();
  }

  bool get canProceedToSchedule {
    return titleController.text.trim().isNotEmpty &&
           durationController.text.trim().isNotEmpty &&
           priceController.text.trim().isNotEmpty &&
           _businessId != null;
  }

  bool _hasAtLeastOneSchedule() {
    // Check if there's at least one location with class availability enabled and complete schedules
    return _schedulesByLocation.entries.any((entry) {
      final locationId = entry.key;
      final schedules = entry.value;
      final isAvailable = _classAvailabilityByLocation[locationId] ?? false;
      
      return isAvailable && schedules.isNotEmpty && _hasCompleteScheduleForLocation(locationId);
    });
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
      
      // Print payload instead of calling API (backend route is in development)
      print('=== FINAL PAYLOAD FOR BACKEND ===');
      print('Payload: $payload');
      print('=====================================');
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> _buildSavePayload() {
    final serviceDetail = {
      'business_id': _businessId,
      'name': titleController.text.trim(),
      'description': descriptionController.text.trim(),
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
    };

    // Build location schedules
    final List<Map<String, dynamic>> locationSchedules = [];
    
    for (var entry in _schedulesByLocation.entries) {
      final locationId = entry.key;
      final schedules = entry.value;
      final isAvailable = _classAvailabilityByLocation[locationId] ?? false;
      
      // Only include locations where class availability is enabled and has schedules
      if (isAvailable && schedules.isNotEmpty) {
        final locationSchedule = {
          'location_id': locationId,
          'class_available': true,
          'schedules': schedules.map((schedule) => {
            'day_of_week': schedule['day'],
            'start_time': schedule['start_time'],
            'end_time': schedule['end_time'],
            'instructor_ids': schedule['instructor_ids'] ?? [],
            if (schedule['spots_available'] != null) 
              'spots_available': schedule['spots_available'],
          }).toList(),
        };
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