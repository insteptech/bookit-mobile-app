import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/class_schedule_selector.dart';
import 'package:flutter/material.dart';

class AddClassScheduleScreen extends StatefulWidget {
  final String? classId;
  
  const AddClassScheduleScreen({
    super.key,
    this.classId,
  });

  @override
  State<AddClassScheduleScreen> createState() => _AddClassScheduleScreenState();
}

class _AddClassScheduleScreenState extends State<AddClassScheduleScreen> {
  String? selectedClassId;
  String? selectedLocationId;
  String? businessId;
  bool isLoading = false;
  bool isSubmitting = false;
  List<Map<String, dynamic>> allStaffMembers = [];
  List<Map<String, dynamic>> filteredStaffMembers = [];
  
  Map<String, dynamic>? existingScheduleData;
  String? existingLocationScheduleId;
  
  final GlobalKey<ClassScheduleSelectorState> _scheduleSelectorKey = GlobalKey<ClassScheduleSelectorState>();

  bool locationPricingEnabled = false;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController packageAmountController = TextEditingController();
  final TextEditingController packagePersonController = TextEditingController();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    priceController.dispose();
    packageAmountController.dispose();
    packagePersonController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    print("=== _initialize called ===");
    print("widget.classId: '${widget.classId}'");
    print("widget.classId != null: ${widget.classId != null}");
    
    await fetchBusinessId();
    await Future.wait([
      fetchLocations(),
      fetchStaffMembers(),
      fetchClasses(),
    ]);
    
    print("After fetching data - classes.length: ${classes.length}");
    
    // Auto-select class logic
    String? classIdToSelect;
    
    // First priority: use provided widget.classId if it exists and is not empty
    if (widget.classId != null && widget.classId!.trim().isNotEmpty) {
      classIdToSelect = widget.classId;
      print("Using provided classId: $classIdToSelect");
    } 
    // Second priority: auto-select first class if no classId provided
    else if (classes.isNotEmpty) {
      classIdToSelect = classes.first['id'];
      print("Auto-selecting first class: $classIdToSelect (${classes.first['name']})");
    }
    
    // If we have a class to select, set it and fetch its data
    if (classIdToSelect != null && mounted) {
      setState(() {
        selectedClassId = classIdToSelect;
      });
      await fetchClassData(classIdToSelect);
    } else {
      print("No class to auto-select - classIdToSelect: $classIdToSelect, mounted: $mounted");
    }
    
    print("=== End _initialize ===");
  }

  Future<void> fetchBusinessId() async {
    try {
      String activeBusinessId = await ActiveBusinessService().getActiveBusiness() as String;
      if (mounted) {
        setState(() {
          businessId = activeBusinessId;
        });
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
    }
  }

  Future<void> fetchClassData(String classId) async {
    print("=== fetchClassData called with classId: $classId ===");
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await APIRepository.getClassDetails(classId);

      print("Fetch class data Response: $response");
      
      if (response['data'] != null) {
        final data = response['data']['data'];
        print("Found class data, calling _prefillFormFromExistingData");
        
        setState(() {
          existingScheduleData = data;
          isLoading = false;
        });
        
        // Call prefill outside setState to avoid nested setState calls
        _prefillFormFromExistingData(data);
      } else {
        print("No class data found in response");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching class data: $e");
      setState(() {
        isLoading = false;
      });
    }
    print("=== End fetchClassData ===");
  }

void _prefillFormFromExistingData(Map<String, dynamic> responseData) {
  print("=== _prefillFormFromExistingData called ===");
  final data = responseData;
  
  final classId = data['class_id'] ?? data['id'];
  final businessIdFromData = data['business_id'];
  
  print("Class ID from data: $classId");
  print("Business ID from data: $businessIdFromData");
  print("Schedules count: ${data['schedules']?.length ?? 0}");
  
  selectedClassId = classId;
  businessId = businessIdFromData;
  
  if (data['schedules'] != null && data['schedules'].isNotEmpty) {
    // Group schedules by location to handle multiple schedules per location
    final schedulesByLocation = <String, List<Map<String, dynamic>>>{};
    
    for (var schedule in data['schedules']) {
      final locationId = schedule['location']?['id'];
      if (locationId != null) {
        schedulesByLocation.putIfAbsent(locationId, () => []);
        schedulesByLocation[locationId]!.add(schedule);
      }
    }
    
    print("=== _prefillFormFromExistingData Debug ===");
    print("Total schedules: ${data['schedules'].length}");
    print("Grouped by locations: ${schedulesByLocation.keys.toList()}");
    for (var locationId in schedulesByLocation.keys) {
      print("Location $locationId has ${schedulesByLocation[locationId]!.length} schedules");
    }
    
    // Store all schedule data for location switching
    existingScheduleData = {
      ...data,
      'schedulesByLocation': schedulesByLocation,
    };
    
    // Auto-select the first location
    final firstLocationId = schedulesByLocation.keys.first;
    selectedLocationId = firstLocationId;
    print("Auto-selected first location: $firstLocationId");
    
    // Update form with first location's data
    _updateFormForLocation(firstLocationId);
    print("=== End _prefillFormFromExistingData ===");
  }
}

void _updateFormForLocation(String locationId) {
  print("=== _updateFormForLocation Debug ===");
  print("locationId: $locationId");
  print("existingScheduleData != null: ${existingScheduleData != null}");
  
  if (existingScheduleData == null) {
    print("No existingScheduleData available");
    return;
  }
  
  final schedulesByLocation = existingScheduleData!['schedulesByLocation'] as Map<String, List<Map<String, dynamic>>>;
  print("Available location IDs: ${schedulesByLocation.keys.toList()}");
  
  final locationSchedules = schedulesByLocation[locationId];
  print("Schedules for location $locationId: ${locationSchedules?.length ?? 0} schedules");
  
  if (locationSchedules == null || locationSchedules.isEmpty) {
    print("No schedules found for location $locationId");
    // Clear form for location without data
    setState(() {
      locationPricingEnabled = false;
      priceController.clear();
      packageAmountController.clear();
      packagePersonController.clear();
    });
    
    // Clear schedule selector
    if (_scheduleSelectorKey.currentState != null) {
      _scheduleSelectorKey.currentState!.clearAll();
    }
    return;
  }
  
  final firstSchedule = locationSchedules.first;
  print("First schedule pricing: price=${firstSchedule['price']}, package_amount=${firstSchedule['package_amount']}, package_person=${firstSchedule['package_person']}");
  
  setState(() {
    // Handle pricing - check if any schedule has pricing information
    bool hasPricing = locationSchedules.any((schedule) => 
      schedule['price'] != null || 
      schedule['package_amount'] != null || 
      schedule['package_person'] != null
    );
    
    if (hasPricing) {
      locationPricingEnabled = true;
      print("Enabling location pricing for location $locationId");
      
      // Use the first schedule's pricing as default
      if (firstSchedule['price'] != null) {
        priceController.text = firstSchedule['price'].toString();
        print("Set price to: ${firstSchedule['price']}");
      }
      if (firstSchedule['package_amount'] != null) {
        packageAmountController.text = firstSchedule['package_amount'].toString();
        print("Set package amount to: ${firstSchedule['package_amount']}");
      }
      if (firstSchedule['package_person'] != null) {
        packagePersonController.text = firstSchedule['package_person'].toString();
        print("Set package person to: ${firstSchedule['package_person']}");
      }
    } else {
      locationPricingEnabled = false;
      priceController.clear();
      packageAmountController.clear();
      packagePersonController.clear();
      print("Cleared pricing for location $locationId (no pricing data)");
    }
  });
  
  // Convert schedules to the expected format
  final convertedSchedules = <Map<String, String>>[];
  final originalSchedules = <Map<String, dynamic>>[];
  
  for (var schedule in locationSchedules) {
    // Extract instructor IDs and names from the new API structure
    final instructors = schedule['instructors'] as List<dynamic>? ?? [];
    final instructorIds = <String>[];
    final instructorNames = <String>[];
    
    for (var instructor in instructors) {
      if (instructor['id'] != null) {
        instructorIds.add(instructor['id'].toString());
      }
      if (instructor['name'] != null) {
        instructorNames.add(instructor['name'].toString());
      }
    }
    
    convertedSchedules.add({
      'day': (schedule['day_of_week'] ?? '').toString().toLowerCase(),
      'from': schedule['start_time']?.toString() ?? '',
      'to': schedule['end_time']?.toString() ?? '',
      'instructors': instructorNames.join(','), // For display
      'instructor_ids': instructorIds.join(','), // Actual IDs
    });
    
    // Keep original schedule data for reference
    originalSchedules.add({
      'id': schedule['id'],
      'day': schedule['day_of_week'],
      'start_time': schedule['start_time'],
      'end_time': schedule['end_time'],
      'instructors': instructors,
      'instructor_ids': instructorIds, // Pass as List<String>
      'price': schedule['price'],
      'package_amount': schedule['package_amount'],
      'package_person': schedule['package_person'],
    });
  }
  
  _filterStaffByLocation();
  
  print("Converting ${locationSchedules.length} schedules for location $locationId");
  print("convertedSchedules: $convertedSchedules");
  
  // Clear the schedule selector first to ensure clean state
  if (_scheduleSelectorKey.currentState != null) {
    print("Clearing schedule selector before updating");
    _scheduleSelectorKey.currentState!.clearAll();
  }
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print("Initializing schedule selector with converted schedules");
    _initializeScheduleSelector(convertedSchedules, originalSchedules);
  });
  
  print("=== End _updateFormForLocation ===");
}

  void _initializeScheduleSelector(List<Map<String, String>> schedules, List<dynamic> originalSchedules) {
    if (_scheduleSelectorKey.currentState != null) {
      _scheduleSelectorKey.currentState!.initializeWithExistingData(schedules, originalSchedules);
      
      // Trigger setState to update the UI after initialization
      if (mounted) {
        setState(() {
          // This triggers a rebuild to reflect the initialized schedule data
        });
      }
    }
  }

  Future<void> fetchClasses() async {
    try {
      final response = await APIRepository.getAllClasses();
      print("Fetch classes Response: $response");

      if (response['data'] != null) {
        final List<dynamic> dataList = response['data']['data'];
        final Set<String> addedServiceIds = {};

        classes = [];

        for (var classItem in dataList) {
          final serviceDetails = classItem['service_details'] as List<dynamic>;

          for (var detail in serviceDetails) {
            final serviceId = detail['service_id'] as String;
            final serviceName = detail['name'] ?? 'Unnamed Class';
            
            final durations = detail['durations'] as List<dynamic>;

            //extracting first duration only
            final duration = durations.first['duration_minutes'];

            if (!addedServiceIds.contains(serviceId)) {
              classes.add({
                'id': serviceId,
                'name': serviceName,
                'duration': duration,
              });
              addedServiceIds.add(serviceId);
            }
          }
        }

        if (mounted) {
          setState(() {
            // Classes have been loaded
          });
          print("Classes loaded: ${classes.length} classes available");
          print("Classes: ${classes.map((c) => '${c['id']}: ${c['name']}').toList()}");
        }
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
    }
  }

  Future<void> fetchStaffMembers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await APIRepository.getAllStaffList();
      final rows = response.data['data']['rows'] as List<dynamic>;

      print("Fetch staff members Response: $rows");

      if (mounted) {
        setState(() {
          allStaffMembers = rows.cast<Map<String, dynamic>>();
          _filterStaffByLocation();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching staff: $e")),
        );
      }
    }
  }

  Future<void> fetchLocations() async {
  try {
    final response = await APIRepository.getBusinessLocations();
    final locationsData = response['rows'] as List<dynamic>;

    if (mounted) {
      setState(() {
        locations = locationsData.map((loc) => {
          'id': loc['id'].toString(),
          'title': loc['title'].toString(),
          // Store the actual location ID for matching
          'location_id': loc['id'].toString(),
        }).toList();

        print("Fetch locations Response: $locations");
        
        if (locations.isNotEmpty && selectedLocationId == null && widget.classId == null) {
          selectedLocationId = locations[0]['id'].toString();
          _filterStaffByLocation();
        }
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching locations: $e")),
      );
    }
  }
}

  void _filterStaffByLocation() {
    print("=== _filterStaffByLocation Debug ===");
    print("selectedLocationId: $selectedLocationId");
    print("allStaffMembers count: ${allStaffMembers.length}");
    
    if (selectedLocationId == null) {
      filteredStaffMembers = [];
      print("No location selected, cleared filtered staff");
      return;
    }

    filteredStaffMembers = allStaffMembers.where((staff) {
      final locationIds = staff['location_id'];
      
      if (locationIds == null) {
        return false;
      }
      
      List<String> locationIdsList = [];
      
      if (locationIds is List) {
        locationIdsList = locationIds.map((id) => id.toString()).toList();
      } else if (locationIds is String) {
        locationIdsList = [locationIds];
      } else {
        return false;
      }
      
      return locationIdsList.contains(selectedLocationId.toString());
    }).toList();
    
    print("Filtered staff count: ${filteredStaffMembers.length}");
    print("Filtered staff: ${filteredStaffMembers.map((s) => '${s['id']}: ${s['name']}').toList()}");
    print("=== End _filterStaffByLocation ===");
  }

  void _onLocationChanged(String? newLocationId) {
    final currentLocationStr = selectedLocationId?.toString();
    final newLocationStr = newLocationId?.toString();
    
    print("=== _onLocationChanged Debug ===");
    print("currentLocationStr: $currentLocationStr");
    print("newLocationStr: $newLocationStr");
    print("existingScheduleData != null: ${existingScheduleData != null}");
    
    if (newLocationStr != currentLocationStr) {
      setState(() {
        selectedLocationId = newLocationStr;
        existingLocationScheduleId = null;
        
        print("Location changed to: $selectedLocationId");
        
        // Update form data based on new location if we have existing schedule data
        if (existingScheduleData != null && newLocationStr != null) {
          print("Updating form for existing location data");
          // Note: _updateFormForLocation calls setState internally, so we don't need to wrap it here
        } else {
          print("No existing data, resetting form");
          // Reset form if no existing data for this location
          locationPricingEnabled = false;
          priceController.clear();
          packageAmountController.clear();
          packagePersonController.clear();
          
          // Clear schedule selector
          if (_scheduleSelectorKey.currentState != null) {
            _scheduleSelectorKey.currentState!.clearAll();
          }
        }
        
        _filterStaffByLocation();
      });
      
      // Call _updateFormForLocation outside setState since it has its own setState
      if (existingScheduleData != null && newLocationStr != null) {
        _updateFormForLocation(newLocationStr);
      }
    }
    print("===============================");
  }

  ClassScheduleController? get _getScheduleController {
    return _scheduleSelectorKey.currentState?.controller;
  }

  Map<String, dynamic> _generateBackendPayload() {
    if (selectedLocationId == null || selectedClassId == null || businessId == null) {
      throw Exception('Missing required fields');
    }

    final controller = _getScheduleController;
    
    if (controller != null && controller.isValid) {
      // Only parse pricing values if pricing is enabled AND fields have valid values
      double? price;
      double? packageAmount;
      int? packagePerson;
      
      if (locationPricingEnabled) {
        // Only include non-empty values
        if (priceController.text.trim().isNotEmpty) {
          price = double.tryParse(priceController.text.trim());
        }
        if (packageAmountController.text.trim().isNotEmpty) {
          packageAmount = double.tryParse(packageAmountController.text.trim());
        }
        if (packagePersonController.text.trim().isNotEmpty) {
          packagePerson = int.tryParse(packagePersonController.text.trim());
        }
      }
      
      print("=== Payload Generation Debug ===");
      print("locationPricingEnabled: $locationPricingEnabled");
      print("priceController.text: '${priceController.text}'");
      print("packageAmountController.text: '${packageAmountController.text}'");
      print("packagePersonController.text: '${packagePersonController.text}'");
      print("Final pricing values - price: $price, packageAmount: $packageAmount, packagePerson: $packagePerson");

      final payload = controller.buildBackendPayload(
        businessId: businessId!,
        classId: selectedClassId!,
        locationId: selectedLocationId!,
        price: price,
        packageAmount: packageAmount,
        packagePerson: packagePerson,
      );

      if (existingLocationScheduleId != null) {
        payload['location_schedules'][0]['id'] = existingLocationScheduleId;
      }

      print("Final payload: $payload");
      print("=== End Payload Generation ===");

      return payload;
    } else {
      throw Exception('Invalid schedule data');
    }
  }

  Future<void> _submitSchedule() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final backendPayload = _generateBackendPayload();
      print("Submitting schedule with payload: $backendPayload");
      await APIRepository.postClassDetails(payload: backendPayload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingLocationScheduleId != null 
                ? 'Schedule updated successfully!' 
                : 'Schedule added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${existingLocationScheduleId != null ? 'update' : 'add'} schedule: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  bool get _canSubmit {
    final controller = _getScheduleController;
    
    bool canSubmit = false;
    
    if (controller != null) {
      canSubmit = selectedClassId != null &&
          selectedLocationId != null &&
          businessId != null &&
          controller.isValid;
          
      // Debug logging
      print("=== _canSubmit Debug ===");
      print("selectedClassId: $selectedClassId");
      print("selectedLocationId: $selectedLocationId");
      print("businessId: $businessId");
      print("controller.isValid: ${controller.isValid}");
      print("controller.schedules: ${controller.schedules.map((s) => '${s.day}: instructors=${s.instructors.length}')}");
      print("canSubmit: $canSubmit");
      print("=====================");
    }
    
    return canSubmit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 32),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          AppTranslationsDelegate.of(context).text("class_schedule"),
                          style: AppTypography.headingLg,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTranslationsDelegate.of(context).text("class_schedule_description"),
                          style: AppTypography.bodyMedium,
                        ),
                        
                        const SizedBox(height: 40),

                        Text(
                          'Select class',
                          style: AppTypography.headingSm
                        ),
                        const SizedBox(height: 16),
                        
                        Column(
                          children: classes.map((classItem) {
                            final isSelected = selectedClassId == classItem['id'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GestureDetector(
                                onTap: () async {
                                  // Clear existing form data when selecting a new class
                                  setState(() {
                                    selectedClassId = classItem['id'];
                                    selectedLocationId = null;
                                    existingScheduleData = null;
                                    existingLocationScheduleId = null;
                                    locationPricingEnabled = false;
                                    priceController.clear();
                                    packageAmountController.clear();
                                    packagePersonController.clear();
                                    print("Selected class id: $selectedClassId");
                                  });
                                  
                                  // Clear schedule selector
                                  if (_scheduleSelectorKey.currentState != null) {
                                    _scheduleSelectorKey.currentState!.clearAll();
                                  }
                                  
                                  if (selectedClassId != null) {
                                    await fetchClassData(selectedClassId!);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      classItem['name'] ?? '',
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),
                        
                        // GestureDetector(
                        //   onTap: () {
                        //     // Navigate to 'See all classes' screen
                        //   },
                        //   child: Text(
                        //     'See all',
                        //     style: AppTypography.bodyMedium.copyWith(
                        //       color: Theme.of(context).colorScheme.primary,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 32),

                        Text(
                          'Select location for this schedule',
                          style: AppTypography.headingSm
                        ),
                        const SizedBox(height: 16),
                        
                        Column(
                          children: locations.map((location) {
                            final isSelected = selectedLocationId == location['id'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  print("Location tapped: ${location['id']} (${location['title']})");
                                  _onLocationChanged(location['id']);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      location['title'] ?? '',
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Pricing details', 
                          style: AppTypography.headingSm
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Set custom pricing for this location?',
                              style: AppTypography.bodyMedium,
                            ),
                            Switch(
                              value: locationPricingEnabled,
                              onChanged: (value) {
                                setState(() {
                                  locationPricingEnabled = value;
                                  if (!value) {
                                    priceController.clear();
                                    packageAmountController.clear();
                                    packagePersonController.clear();
                                  }
                                });
                              },
                              activeColor: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        
                        if (locationPricingEnabled) ...[
                          const SizedBox(height: 16),
                          
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Regular price", style: AppTypography.bodyMedium),
                                Row(
                                  children: [
                                    Text("EGP", style: AppTypography.bodyMedium),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 88,
                                      child: NumericInputBox(
                                        controller: priceController,
                                        hintText: "400",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Package',
                                  style: AppTypography.bodyMedium,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 88,
                                      child: NumericInputBox(
                                        hintText: "10x",
                                        controller: packagePersonController,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 88,
                                      child: NumericInputBox(
                                        hintText: "3000",
                                        controller: packageAmountController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        
                        if (isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          ClassScheduleSelector(
                            key: _scheduleSelectorKey,
                            staffMembers: filteredStaffMembers,
                            onScheduleUpdate: (schedules) {
                              // Handle schedule updates if needed
                            },
                          ),

                        const SizedBox(height: 32),
                        
                        GestureDetector(
                          onTap: () {
                            // Setup another class functionality
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Setup another class',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(34, 0, 34, 24),
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: existingLocationScheduleId != null ? 'Update' : 'Done',
                        isDisabled: !_canSubmit || isSubmitting,
                        onPressed: _submitSchedule,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}