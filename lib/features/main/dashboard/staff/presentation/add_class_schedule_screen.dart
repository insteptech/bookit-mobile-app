import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/custom_switch.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/class_schedule_selector.dart';
import 'package:flutter/material.dart';

class AddClassScheduleScreen extends StatefulWidget {
  final String? classId;
  final String? className;
  
  const AddClassScheduleScreen({
    super.key,
    this.classId,
    this.className
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
  int? classDurationMinutes;
  
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
    await fetchBusinessId();
    await Future.wait([
      fetchLocations(),
      fetchStaffMembers(),
      fetchClasses(),
    ]);
    
    String? classIdToSelect;
    
    if (widget.classId != null && widget.classId!.trim().isNotEmpty) {
      classIdToSelect = widget.classId;
    } 
    else if (classes.isNotEmpty) {
      classIdToSelect = classes.first['id'];
    }
    
    if (classIdToSelect != null && mounted) {
      // Find the selected class to get its duration
      final selectedClass = classes.firstWhere(
        (cls) => cls['id'] == classIdToSelect,
        orElse: () => {},
      );
      
      setState(() {
        selectedClassId = classIdToSelect;
        if (selectedClass.isNotEmpty) {
          classDurationMinutes = selectedClass['duration'];
        }
      });
      await fetchClassData(classIdToSelect);
    }
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
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await APIRepository.getClassDetails(classId);
      
      if (response['data'] != null) {
        final data = response['data']['data'];
        
        // Extract class duration from service_details
        int? duration;
        if (data['service_details'] != null && data['service_details'].isNotEmpty) {
          final serviceDetails = data['service_details'][0];
          if (serviceDetails['durations'] != null && serviceDetails['durations'].isNotEmpty) {
            duration = serviceDetails['durations'][0]['duration_minutes'];
          }
        }
        
        setState(() {
          existingScheduleData = data;
          classDurationMinutes = duration;
          isLoading = false;
        });
        
        debugPrint('Fetched class data - Duration: $duration minutes');
        
        _prefillFormFromExistingData(data);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

void _prefillFormFromExistingData(Map<String, dynamic> responseData) {
  final data = responseData;
  
  final classId = data['class_id'] ?? data['id'];
  final businessIdFromData = data['business_id'];
  
  selectedClassId = classId;
  businessId = businessIdFromData;
  
  if (data['schedules'] != null && data['schedules'].isNotEmpty) {
    final schedulesByLocation = <String, List<Map<String, dynamic>>>{};
    
    for (var schedule in data['schedules']) {
      final locationId = schedule['location']?['id'];
      if (locationId != null) {
        schedulesByLocation.putIfAbsent(locationId, () => []);
        schedulesByLocation[locationId]!.add(schedule);
      }
    }
    
    existingScheduleData = {
      ...data,
      'schedulesByLocation': schedulesByLocation,
    };
    
    final firstLocationId = schedulesByLocation.keys.first;
    selectedLocationId = firstLocationId;
    
    _updateFormForLocation(firstLocationId);
  }
}

void _updateFormForLocation(String locationId) {
  if (existingScheduleData == null) {
    return;
  }
  
  final schedulesByLocation = existingScheduleData!['schedulesByLocation'] as Map<String, List<Map<String, dynamic>>>;
  
  final locationSchedules = schedulesByLocation[locationId];
  
  if (locationSchedules == null || locationSchedules.isEmpty) {
    setState(() {
      locationPricingEnabled = false;
      priceController.clear();
      packageAmountController.clear();
      packagePersonController.clear();
    });
    
    if (_scheduleSelectorKey.currentState != null) {
      _scheduleSelectorKey.currentState!.clearAll();
    }
    return;
  }
  
  final firstSchedule = locationSchedules.first;
  
  setState(() {
    bool hasPricing = locationSchedules.any((schedule) => 
      schedule['price'] != null || 
      schedule['package_amount'] != null || 
      schedule['package_person'] != null
    );
    
    if (hasPricing) {
      locationPricingEnabled = true;
      
      if (firstSchedule['price'] != null) {
        priceController.text = firstSchedule['price'].toString();
      }
      if (firstSchedule['package_amount'] != null) {
        packageAmountController.text = firstSchedule['package_amount'].toString();
      }
      if (firstSchedule['package_person'] != null) {
        packagePersonController.text = firstSchedule['package_person'].toString();
      }
    } else {
      locationPricingEnabled = false;
      priceController.clear();
      packageAmountController.clear();
      packagePersonController.clear();
    }
  });
    
    final convertedSchedules = <Map<String, String>>[];
    final originalSchedules = <Map<String, dynamic>>[];
    
  for (var schedule in locationSchedules) {
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
      'id': schedule['id']?.toString() ?? '',
        'day': (schedule['day_of_week'] ?? '').toString().toLowerCase(),
        'from': schedule['start_time']?.toString() ?? '',
        'to': schedule['end_time']?.toString() ?? '',
        'instructors': instructorNames.join(','),
        'instructor_ids': instructorIds.join(','),
      });
      
      originalSchedules.add({
        'id': schedule['id'],
        'day': schedule['day_of_week'],
        'start_time': schedule['start_time'],
        'end_time': schedule['end_time'],
        'instructors': instructors,
        'instructor_ids': instructorIds,
        'price': schedule['price'],
        'package_amount': schedule['package_amount'],
        'package_person': schedule['package_person'],
      });
    }
    
    _filterStaffByLocation();
  
  if (_scheduleSelectorKey.currentState != null) {
    _scheduleSelectorKey.currentState!.clearAll();
  }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScheduleSelector(convertedSchedules, originalSchedules);
    });
}

  void _initializeScheduleSelector(List<Map<String, String>> schedules, List<dynamic> originalSchedules) {
    if (_scheduleSelectorKey.currentState != null) {
      _scheduleSelectorKey.currentState!.initializeWithExistingData(schedules, originalSchedules);
      
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
            // If we already have a selected class, update its duration
            if (selectedClassId != null) {
              final selectedClass = classes.firstWhere(
                (cls) => cls['id'] == selectedClassId,
                orElse: () => {},
              );
              if (selectedClass.isNotEmpty) {
                classDurationMinutes = selectedClass['duration'];
              }
            }
          });
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
      final response = await APIRepository.getStaffListByBusinessId();
      // final rows = response.data['data']['rows'] as List<dynamic>;
      final rows = response.data['data']['profiles'] as List<dynamic>;


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
          'location_id': loc['id'].toString(),
        }).toList();
        
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
  }

  void _onLocationChanged(String? newLocationId) {
    final currentLocationStr = selectedLocationId?.toString();
    final newLocationStr = newLocationId?.toString();
    
    if (newLocationStr != currentLocationStr) {
      setState(() {
        selectedLocationId = newLocationStr;
        existingLocationScheduleId = null;
        
        if (existingScheduleData != null && newLocationStr != null) {
          // Update form data based on new location if we have existing schedule data
        } else {
          locationPricingEnabled = false;
          priceController.clear();
          packageAmountController.clear();
          packagePersonController.clear();
          
          if (_scheduleSelectorKey.currentState != null) {
            _scheduleSelectorKey.currentState!.clearAll();
          }
        }
        
        _filterStaffByLocation();
      });
      
      if (existingScheduleData != null && newLocationStr != null) {
        _updateFormForLocation(newLocationStr);
    }
    }
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
      double? price;
      double? packageAmount;
      int? packagePerson;
      
      if (locationPricingEnabled) {
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
      print('Submitting schedule with payload: $backendPayload');
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
    
    if (controller != null) {
      return selectedClassId != null &&
          selectedLocationId != null &&
          businessId != null &&
          controller.isValid;
    }
    
    return false;
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
                        if ((widget.classId?.isEmpty ?? true) && (widget.className?.isEmpty ?? true))
                        Text(
                          AppTranslationsDelegate.of(context).text("class_schedule_description"),
                          style: AppTypography.bodyMedium,
                        ),
                        
                        const SizedBox(height: 40),
                        if ((widget.classId?.isEmpty ?? true) && (widget.className?.isEmpty ?? true))
                        Text(
                          'Select class',
                          style: AppTypography.headingSm
                        ),
                        if ((widget.classId?.isEmpty ?? true) && (widget.className?.isEmpty ?? true))
                        const SizedBox(height: 16),
                        if ((widget.classId?.isEmpty ?? true) && (widget.className?.isEmpty ?? true))                        
                        Column( 
                          children: classes.map((classItem) {
                            final isSelected = selectedClassId == classItem['id'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedClassId = classItem['id'];
                                    selectedLocationId = null;
                                    existingScheduleData = null;
                                    existingLocationScheduleId = null;
                                    locationPricingEnabled = false;
                                    priceController.clear();
                                    packageAmountController.clear();
                                    packagePersonController.clear();
                                    // Update duration for the selected class
                                    classDurationMinutes = classItem['duration'];
                                  });
                                  
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

                        if ((widget.classId?.isNotEmpty ?? false) && (widget.className?.isNotEmpty ?? false))
                        Text("${widget.className}", style: AppTypography.headingMd.copyWith(fontWeight: FontWeight.w400),),

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
                          'Location specific pricing', 
                          style: AppTypography.headingSm
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Override price for this location?',
                              style: AppTypography.bodyMedium,
                            ),
                            CustomSwitch(
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
                            classDurationMinutes: classDurationMinutes,
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