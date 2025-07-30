import 'dart:convert';

import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/class_schedule_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddClassScheduleScreen extends StatefulWidget {
  final String? classId; // Optional classId for editing existing schedule
  
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
  
  // Store the existing schedule data for editing
  Map<String, dynamic>? existingScheduleData;
  String? existingLocationScheduleId; // The 'id' from location_schedules
  
  // Use GlobalKey to access the ClassScheduleSelector
  final GlobalKey<ClassScheduleSelectorState> _scheduleSelectorKey = GlobalKey<ClassScheduleSelectorState>();
  
  // Keep this for backward compatibility and debugging
  List<Map<String, dynamic>> currentSchedules = [];

  // Location-specific pricing
  bool locationPricingEnabled = false;
  final TextEditingController priceController = TextEditingController();
  final TextEditingController packageAmountController = TextEditingController();
  final TextEditingController packagePersonController = TextEditingController();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    fetchBusinessId();
    fetchLocations();
    fetchStaffMembers();
    fetchClasses();
  }

  @override
  void dispose() {
    priceController.dispose();
    packageAmountController.dispose();
    packagePersonController.dispose();
    super.dispose();
  }

  Future<void> fetchBusinessId() async {
    String activeBusinessId = await ActiveBusinessService().getActiveBusiness() as String;
    try {
      setState(() {
        businessId = activeBusinessId;
      });
      debugPrint("Business ID set: $businessId");
    } catch (e) {
      debugPrint("Error fetching business ID: $e");
    }
  }

  Future<void> fetchClassData(String classId) async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await APIRepository.getClassDetails(classId);
      
      if (response != null && response['data'] != null) {
        final data = response['data'];
        
        setState(() {
          existingScheduleData = data;
          _prefillFormFromExistingData(data);
          isLoading = false;
        });
        
        debugPrint("Class data loaded for prefill:");
        debugPrint(JsonEncoder.withIndent('  ').convert(data));
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching class data: $e");
    }
  }

  void _prefillFormFromExistingData(Map<String, dynamic> data) {
    // Set class and business IDs
    selectedClassId = data['class_id'];
    businessId = data['business_id'];
    
    // Handle location schedules
    if (data['location_schedules'] != null && data['location_schedules'].isNotEmpty) {
      final locationSchedule = data['location_schedules'][0];
      
      // Store the existing location schedule ID for updates
      existingLocationScheduleId = locationSchedule['id'];
      selectedLocationId = locationSchedule['location_id'];
      
      // Prefill pricing if available
      if (locationSchedule['price'] != null || 
          locationSchedule['package_amount'] != null || 
          locationSchedule['package_person'] != null) {
        locationPricingEnabled = true;
        
        if (locationSchedule['price'] != null) {
          priceController.text = locationSchedule['price'].toString();
        }
        if (locationSchedule['package_amount'] != null) {
          packageAmountController.text = locationSchedule['package_amount'].toString();
        }
        if (locationSchedule['package_person'] != null) {
          packagePersonController.text = locationSchedule['package_person'].toString();
        }
      }
      
      // Convert schedule data for the ClassScheduleSelector
      if (locationSchedule['schedule'] != null) {
        final scheduleList = locationSchedule['schedule'] as List<dynamic>;
        final convertedSchedules = <Map<String, String>>[];
        
        for (var schedule in scheduleList) {
          convertedSchedules.add({
            'day': schedule['day'].toString().toLowerCase(),
            'from': schedule['start_time'].toString(),
            'to': schedule['end_time'].toString(),
            // Store instructors for later use
            'instructors': (schedule['instructors'] as List<dynamic>).join(','),
          });
        }
        
        // Filter staff by location first
        _filterStaffByLocation();
        
        // Set initial schedules for the ClassScheduleSelector
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeScheduleSelector(convertedSchedules, scheduleList);
        });
      }
    }
  }

  void _initializeScheduleSelector(List<Map<String, String>> schedules, List<dynamic> originalSchedules) {
    // Wait for the ClassScheduleSelector to be built, then initialize it
    if (_scheduleSelectorKey.currentState != null) {
      // You'll need to add this method to ClassScheduleSelector to initialize with existing data
      _scheduleSelectorKey.currentState!.initializeWithExistingData(schedules, originalSchedules);
    }
  }

  Future<void> fetchClasses() async {
    try {
      final response = await APIRepository.getAllClasses();

      if (response != null && response['data'] != null) {
        final List<dynamic> dataList = response['data']['data'];
        final Set<String> addedServiceIds = {};

        classes = [];

        for (var classItem in dataList) {
          final serviceDetails = classItem['service_details'] as List<dynamic>;

          for (var detail in serviceDetails) {
            final serviceId = detail['service_id'] as String;
            final serviceName = detail['name'] ?? 'Unnamed Class';

            if (!addedServiceIds.contains(serviceId)) {
              classes.add({
                'id': serviceId,
                'name': serviceName,
              });
              addedServiceIds.add(serviceId);
            }
          }
        }

        setState(() async {
          // If we have a classId passed from parent (editing mode), fetch its data
          if (widget.classId != null) {
            selectedClassId = widget.classId;
            await fetchClassData(widget.classId!);
          } else if (classes.isNotEmpty && selectedClassId == null) {
            selectedClassId = classes[0]['id'];
            debugPrint("Auto-selected first class: $selectedClassId");
          }
        });

        debugPrint('Classes loaded: ${classes.length} classes');
        debugPrint('Classes:\n${JsonEncoder.withIndent('  ').convert(classes)}');
      }
    } catch (e) {
      debugPrint("Error fetching classes: $e");
    }
  }

  Future<void> fetchStaffMembers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await APIRepository.getAllStaffList();
      final rows = response.data['data']['rows'] as List<dynamic>;

      if (mounted) {
        setState(() {
          allStaffMembers = rows.cast<Map<String, dynamic>>();
          _filterStaffByLocation();
          isLoading = false;
        });
        debugPrint("Staff members loaded: ${allStaffMembers.length} staff");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        debugPrint("Error fetching staff: $e");
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
          }).toList();
          
          // Only auto-select if not in editing mode
          if (locations.isNotEmpty && selectedLocationId == null && widget.classId == null) {
            selectedLocationId = locations[0]['id'].toString();
            debugPrint("Auto-selected first location: $selectedLocationId");
            _filterStaffByLocation();
          }
        });
        debugPrint("Locations loaded: ${locations.length} locations");
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching locations: $e")),
        );
      }
    }
  }

  void _filterStaffByLocation() {
    if (selectedLocationId == null) {
      filteredStaffMembers = [];
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
    
    debugPrint("Filtered staff for location $selectedLocationId: ${filteredStaffMembers.length} staff");
  }

  void _onLocationChanged(String? newLocationId) {
    final currentLocationStr = selectedLocationId?.toString();
    final newLocationStr = newLocationId?.toString();
    
    if (newLocationStr != currentLocationStr) {
      setState(() {
        selectedLocationId = newLocationStr;
        currentSchedules.clear();
        // Clear existing location schedule ID when location changes
        existingLocationScheduleId = null;
        _filterStaffByLocation();
      });
      debugPrint("Location changed to: $selectedLocationId");
    }
  }

  void _handleScheduleUpdate(List<Map<String, dynamic>> schedules) {
    setState(() {
      currentSchedules = schedules;
    });
    debugPrint("Schedule updated: ${currentSchedules.length} schedules");
    debugPrint("Current schedules: $currentSchedules");
    _debugCanSubmit();
  }

  // Get the controller from the ClassScheduleSelector
  ClassScheduleController? get _getScheduleController {
    return _scheduleSelectorKey.currentState?.controller;
  }

  void _debugCanSubmit() {
    final controller = _getScheduleController;
    debugPrint("=== DEBUG CAN SUBMIT ===");
    debugPrint("selectedClassId: $selectedClassId");
    debugPrint("selectedLocationId: $selectedLocationId");
    debugPrint("businessId: $businessId");
    debugPrint("existingLocationScheduleId: $existingLocationScheduleId");
    debugPrint("currentSchedules.isNotEmpty: ${currentSchedules.isNotEmpty}");
    debugPrint("scheduleController?.isValid: ${controller?.isValid}");
    debugPrint("Can submit: $_canSubmit");
    debugPrint("========================");
  }

  Map<String, dynamic> _generateBackendPayload() {
    if (selectedLocationId == null || selectedClassId == null || businessId == null) {
      throw Exception('Missing required fields');
    }

    final controller = _getScheduleController;
    
    if (controller != null && controller.isValid) {
      // Use the new controller method for proper backend format
      final price = locationPricingEnabled ? double.tryParse(priceController.text) : null;
      final packageAmount = locationPricingEnabled ? double.tryParse(packageAmountController.text) : null;
      final packagePerson = locationPricingEnabled ? int.tryParse(packagePersonController.text) : null;

      final payload = controller.buildBackendPayload(
        businessId: businessId!,
        classId: selectedClassId!,
        locationId: selectedLocationId!,
        price: price,
        packageAmount: packageAmount,
        packagePerson: packagePerson,
      );

      // Add the existing ID if we're updating
      if (existingLocationScheduleId != null) {
        payload['location_schedules'][0]['id'] = existingLocationScheduleId;
      }

      return payload;
    } else {
      // Fallback to legacy format if controller is not available
      List<Map<String, dynamic>> transformedSchedules = [];
      
      for (var schedule in currentSchedules) {
        String formattedDay = schedule['day'].toString();
        formattedDay = formattedDay[0].toUpperCase() + formattedDay.substring(1);
        
        String startTime = schedule['startTime']?.toString() ?? '';
        String endTime = schedule['endTime']?.toString() ?? '';
        
        if (startTime.length > 5 && startTime.contains(':')) {
          startTime = startTime.substring(0, 5);
        }
        if (endTime.length > 5 && endTime.contains(':')) {
          endTime = endTime.substring(0, 5);
        }

        transformedSchedules.add({
          'day': formattedDay,
          'start_time': startTime,
          'end_time': endTime,
          'instructors': schedule['staffId'] != null ? [schedule['staffId']] : [],
        });
      }

      final price = locationPricingEnabled ? double.tryParse(priceController.text) : null;
      final packageAmount = locationPricingEnabled ? double.tryParse(packageAmountController.text) : null;
      final packagePerson = locationPricingEnabled ? int.tryParse(packagePersonController.text) : null;

      final locationSchedule = {
        'location_id': selectedLocationId,
        'price': price,
        'package_amount': packageAmount,
        'package_person': packagePerson,
        'schedule': transformedSchedules,
      };

      // Add the existing ID if we're updating
      if (existingLocationScheduleId != null) {
        locationSchedule['id'] = existingLocationScheduleId;
      }

      return {
        'business_id': businessId,
        'class_id': selectedClassId,
        'location_schedules': [locationSchedule]
      };
    }
  }

  Future<void> _submitSchedule() async {
    debugPrint("Submit button pressed!");
    
    if (!_canSubmit) {
      debugPrint("Cannot submit - validation failed");
      _debugCanSubmit();
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final backendPayload = _generateBackendPayload();
      
      debugPrint('Backend Payload:');
      debugPrint(JsonEncoder.withIndent('  ').convert(backendPayload));

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
      debugPrint("Error submitting schedule: $e");
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
    
    // Try the new controller validation first
    if (controller != null) {
      return selectedClassId != null &&
          selectedLocationId != null &&
          businessId != null &&
          controller.isValid;
    }
    
    // Fallback to legacy validation
    return selectedClassId != null &&
        selectedLocationId != null &&
        businessId != null &&
        currentSchedules.isNotEmpty &&
        currentSchedules.every((schedule) => schedule['staffId'] != null);
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
                                  setState(() {
                                    selectedClassId = classItem['id'];
                                  });
                                  debugPrint("Class selected: $selectedClassId");
                                  
                                  // Fetch class data to prefill form
                                  await fetchClassData(selectedClassId!);
                                  _debugCanSubmit();
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
                        
                        GestureDetector(
                          onTap: () {
                            debugPrint("Navigate to 'See all classes' screen.");
                          },
                          child: Text(
                            'See all',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

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
                                  _onLocationChanged(location['id']);
                                  _debugCanSubmit();
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

                        // Location specific pricing section
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
                          
                          // Regular price
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
                          
                          // Package pricing
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
                            onScheduleUpdate: _handleScheduleUpdate,
                          ),

                        const SizedBox(height: 32),
                        
                        GestureDetector(
                          onTap: () {
                            debugPrint("Setup another class tapped.");
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
                        onPressed: () {
                          debugPrint("${existingLocationScheduleId != null ? 'Update' : 'Done'} button tapped!");
                          _submitSchedule();
                        },
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