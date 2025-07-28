import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/class_schedule_selector.dart';
import 'package:flutter/material.dart';

class AddClassScheduleScreen extends StatefulWidget {
  const AddClassScheduleScreen({super.key});

  @override
  State<AddClassScheduleScreen> createState() => _AddClassScheduleScreenState();
}

class _AddClassScheduleScreenState extends State<AddClassScheduleScreen> {
  String? selectedClassId;
  String? selectedLocationId;
  bool isLoading = false;
  bool isSubmitting = false;
  List<Map<String, dynamic>> allStaffMembers = [];
  List<Map<String, dynamic>> filteredStaffMembers = [];
  List<Map<String, dynamic>> currentSchedules = [];

  List<Map<String, dynamic>> classes = [
    {"id": "1", "name": "Advanced Animal Flow"},
    {"id": "2", "name": "Dynamic Pilates"},
    {"id": "3", "name": "Pilates Foundations"},
    {"id": "4", "name": "Strength & Flow"},
  ];

  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
    selectedClassId = classes.isNotEmpty ? classes[0]['id'] : null;
    fetchStaffMembers();
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
          }).toList();
          
          if (locations.isNotEmpty) {
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

  // Future<void> fetchClasses

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
        currentSchedules.clear();
        _filterStaffByLocation();
      });
    }
  }

  void _handleScheduleUpdate(List<Map<String, dynamic>> schedules) {
    setState(() {
      currentSchedules = schedules;
    });
  }

  Map<String, dynamic> _generatePayload() {
    List<Map<String, dynamic>> schedules = [];
    
    for (var schedule in currentSchedules) {
      schedules.add({
        'day': schedule['day'],
        'start_time': schedule['startTime'],
        'end_time': schedule['endTime'],
        'staff_id': schedule['staffId'],
      });
    }

    return {
      'class_id': selectedClassId,
      'location_id': selectedLocationId,
      'schedules': schedules,
    };
  }

  Future<void> _submitSchedule() async {
    if (!_canSubmit) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final payload = _generatePayload();
      // await APIRepository.createClassSchedule(payload);
      print(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add schedule: $e'),
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
    return selectedClassId != null &&
        selectedLocationId != null &&
        currentSchedules.isNotEmpty &&
        currentSchedules.every((schedule) => schedule['staffId'] != null);
  }

  @override
  Widget build(BuildContext context) {
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
                                onTap: () {
                                  setState(() {
                                    selectedClassId = classItem['id'];
                                  });
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
                            key: ValueKey(selectedLocationId),
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
                        text: 'Done',
                        isDisabled: isSubmitting, 
                        onPressed: (_canSubmit && !isSubmitting)
                            ? _submitSchedule
                            : null,
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