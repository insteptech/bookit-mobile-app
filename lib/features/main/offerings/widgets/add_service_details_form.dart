import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/small_fixed_text_box.dart';

class EnhancedServiceFormData {
  final String serviceId;
  final bool isClass;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<Map<String, dynamic>> durationAndCosts = [
    {
      "duration": "",
      "cost": "",
      "packageAmount": "",
      "packagePerson": "",
      "durationController": TextEditingController(),
      "costController": TextEditingController(),
      "packageAmountController": TextEditingController(),
      "packagePersonController": TextEditingController(),
    },
  ];
  
  // Location pricing
  bool locationPricingEnabled = false;
  String selectedLocationId = '';
  final Map<String, TextEditingController> locationPriceControllers = {};
  
  // Staff members
  final List<String> selectedStaffIds = [];
  
  // Tags
  final List<String> selectedTags = [];

  EnhancedServiceFormData({required this.serviceId, required this.isClass});

  // Helper method to get or create location price controller
  TextEditingController getLocationPriceController(String key) {
    if (!locationPriceControllers.containsKey(key)) {
      locationPriceControllers[key] = TextEditingController();
    }
    return locationPriceControllers[key]!;
  }

  Map<String, dynamic>? toJson(String businessId) {
    final durationList = durationAndCosts
        .where((item) {
          return item['duration'].toString().isNotEmpty &&
              item['cost'].toString().isNotEmpty;
        })
        .map((item) {
          final map = {
            'duration_minutes': int.tryParse(item['duration'] ?? '0') ?? 0,
            'price': int.tryParse(item['cost'] ?? '0') ?? 0,
          };
          if ((item['packageAmount'] ?? '').isNotEmpty) {
            map['package_amount'] = int.tryParse(item['packageAmount']) ?? 0;
          }
          if ((item['packagePerson'] ?? '').isNotEmpty) {
            map['package_person'] = int.tryParse(item['packagePerson']) ?? 0;
          }
          return map;
        })
        .toList();

    if (titleController.text.trim().isEmpty || durationList.isEmpty) {
      return null;
    }

    // Build location pricing
    List<Map<String, dynamic>> locationPricingList = [];
    if (locationPricingEnabled && selectedLocationId.isNotEmpty) {
      for (var item in durationAndCosts) {
        if (item['duration'].toString().isNotEmpty) {
          final locationKey = '${selectedLocationId}_${item['duration']}';
          final locationController = locationPriceControllers[locationKey];
          if (locationController != null && locationController.text.isNotEmpty) {
            locationPricingList.add({
              'location_id': selectedLocationId,
              'duration_minutes': int.tryParse(item['duration']) ?? 0,
              'price': int.tryParse(locationController.text) ?? 0,
            });
          }
        }
      }
    }

    return {
      'business_id': businessId,
      'service_id': serviceId,
      'name': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'is_class': isClass,
      'is_archived': false,
      'tags': selectedTags,
      'media_url': '', // You can add media upload functionality
      'staff_ids': isClass ? [] : selectedStaffIds,
      'durations': durationList,
      'location_pricing': locationPricingList,
    };
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    for (var item in durationAndCosts) {
      item['durationController']?.dispose();
      item['costController']?.dispose();
      item['packageAmountController']?.dispose();
      item['packagePersonController']?.dispose();
    }
    for (var controller in locationPriceControllers.values) {
      controller.dispose();
    }
  }
}

class EnhancedServicesForm extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  const EnhancedServicesForm({super.key, required this.serviceData});

  @override
  State<EnhancedServicesForm> createState() => EnhancedServicesFormState();
}

class EnhancedServicesFormState extends State<EnhancedServicesForm> {
  late EnhancedServiceFormData formData;
  
  // Dummy data for staff members
  final List<Map<String, String>> staffMembers = [
    {'id': 'staff1', 'name': 'Fatima Bombo'},
    {'id': 'staff2', 'name': 'Mehdi Hassan'},
    {'id': 'staff3', 'name': 'Nevine Ahmed'},
    {'id': 'staff4', 'name': 'Patricia Sanders'},
  ];
  
  // Dummy data for locations
  final List<Map<String, String>> locations = [
    {'id': 'loc1', 'name': 'Main Studio'},
    {'id': 'loc2', 'name': 'Private Room'},
    {'id': 'loc3', 'name': 'Outdoor Area'},
  ];

  @override
  void initState() {
    super.initState();
    formData = EnhancedServiceFormData(
      serviceId: widget.serviceData['category_id'] ?? '',
      isClass: widget.serviceData['is_class'] ?? false,
    );
    
    // Pre-fill the title with the service title
    formData.titleController.text = widget.serviceData['title'] ?? '';
  }

  @override
  void dispose() {
    formData.dispose();
    super.dispose();
  }

  Map<String, dynamic>? getServiceDetails() {
    return formData.toJson(widget.serviceData['business_id'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClass = formData.isClass;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service name section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Name your service',
                style: AppTypography.headingSm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.delete_outline,
                size: 24,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 12),
          InputField(
            hintText: widget.serviceData['title'] ?? 'Service title',
            controller: formData.titleController,
          ),
          
          SizedBox(height: 24),
          
          // Description section
          Text(
            'Write a short description',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          InputField(
            hintText: 'Personalized assessment and treatment plans address pain, movement limitations, and functional deficits...',
            controller: formData.descriptionController,
            // maxLines: 4,
          ),
          
          SizedBox(height: 24),
          
          // Duration section
          Text(
            'Duration', 
            style: AppTypography.headingSm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Column(
            children: List.generate(formData.durationAndCosts.length, (i) {
              final item = formData.durationAndCosts[i];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SmallFixedTextBox(text: "minutes"),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 88,
                      child: NumericInputBox(
                        controller: item['durationController'] as TextEditingController,
                        onChanged: (value) {
                          setState(() {
                            item['duration'] = value;
                            if (value.isEmpty) {
                              (item['costController'] as TextEditingController?)?.clear();
                              item['cost'] = "";
                              
                              // Clear location pricing controllers for this duration
                              final keysToRemove = formData.locationPriceControllers.keys
                                  .where((key) => key.endsWith('_${item['duration']}'))
                                  .toList();
                              for (var key in keysToRemove) {
                                formData.locationPriceControllers[key]?.dispose();
                                formData.locationPriceControllers.remove(key);
                              }
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    if (formData.durationAndCosts.length > 1)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Dispose controllers before removing
                            (item['durationController'] as TextEditingController?)?.dispose();
                            (item['costController'] as TextEditingController?)?.dispose();
                            (item['packageAmountController'] as TextEditingController?)?.dispose();
                            (item['packagePersonController'] as TextEditingController?)?.dispose();
                            
                            formData.durationAndCosts.remove(item);
                          });
                        },
                        child: Icon(
                          Icons.remove_circle_outline,
                          size: 26,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          GestureDetector(
            onTap: () {
              setState(() {
                formData.durationAndCosts.add({
                  "duration": "",
                  "cost": "",
                  "packageAmount": "",
                  "packagePerson": "",
                  "durationController": TextEditingController(),
                  "costController": TextEditingController(),
                  "packageAmountController": TextEditingController(),
                  "packagePersonController": TextEditingController(),
                });
              });
            },
            child: Text(
              "Add new duration",
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Cost section
          Text(
            'Cost', 
            style: AppTypography.headingSm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Column(
            children: formData.durationAndCosts
                .where((e) => e['duration'].toString().isNotEmpty)
                .map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${item['duration']} min",
                          style: AppTypography.bodyMedium,
                        ),
                        Row(
                          children: [
                            Text("EGP", style: AppTypography.bodyMedium),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 88,
                              child: NumericInputBox(
                                controller: item['costController'] as TextEditingController,
                                onChanged: (val) => setState(() => item['cost'] = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
          
          SizedBox(height: 24),
          
          // Location specific pricing
          Text(
            'Location specific pricing', 
            style: AppTypography.headingSm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Override price for one location?',
                style: AppTypography.bodyMedium,
              ),
              Switch(
                value: formData.locationPricingEnabled,
                onChanged: (value) {
                  setState(() {
                    formData.locationPricingEnabled = value;
                    if (!value) {
                      formData.selectedLocationId = '';
                      // Dispose all location price controllers
                      for (var controller in formData.locationPriceControllers.values) {
                        controller.dispose();
                      }
                      formData.locationPriceControllers.clear();
                    }
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
          
          if (formData.locationPricingEnabled) ...[
            SizedBox(height: 16),
            Text(
              'Cost override', 
              style: AppTypography.headingSm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: formData.selectedLocationId.isEmpty ? null : formData.selectedLocationId,
                  hint: Text(
                    'Choose location',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      formData.selectedLocationId = newValue ?? '';
                      // Initialize controllers for each duration when location is selected
                      if (newValue != null) {
                        for (var item in formData.durationAndCosts) {
                          if (item['duration'].toString().isNotEmpty) {
                            final key = '${newValue}_${item['duration']}';
                            formData.getLocationPriceController(key);
                          }
                        }
                      }
                    });
                  },
                  items: locations.map<DropdownMenuItem<String>>((location) {
                    return DropdownMenuItem<String>(
                      value: location['id'],
                      child: Text(location['name']!),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 12),
            // Location pricing rows
            if (formData.selectedLocationId.isNotEmpty)
              Column(
                children: formData.durationAndCosts
                    .where((e) => e['duration'].toString().isNotEmpty)
                    .map((item) {
                      final locationKey = '${formData.selectedLocationId}_${item['duration']}';
                      final controller = formData.getLocationPriceController(locationKey);
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${item['duration']} min", style: AppTypography.bodyMedium),
                            Row(
                              children: [
                                Text("EGP", style: AppTypography.bodyMedium),
                                SizedBox(width: 12),
                                SizedBox(
                                  width: 88,
                                  child: NumericInputBox(
                                    controller: controller,
                                    hintText: item['cost'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
          ],
          
          // Staff members section (only for non-class services)
          if (!isClass) ...[
            SizedBox(height: 24),
            Text(
              'Staff members', 
              style: AppTypography.headingSm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Choose the staff members who offer this service so it appears on their booking schedules.',
              style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Column(
              children: staffMembers.map((staff) {
                final isSelected = formData.selectedStaffIds.contains(staff['id']);
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              formData.selectedStaffIds.add(staff['id']!);
                            } else {
                              formData.selectedStaffIds.remove(staff['id']);
                            }
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                      Text(staff['name']!, style: AppTypography.bodyMedium),
                    ],
                  ),
                );
              }).toList(),
            ),
            GestureDetector(
              onTap: () {
                // Show all staff members functionality
              },
              child: Text(
                'See all',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}