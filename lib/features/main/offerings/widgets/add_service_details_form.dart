import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/small_fixed_text_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/organisms/drop_down.dart';
import '../../../../shared/components/molecules/checkbox_list_item.dart';

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

  Map<String, dynamic>? toJson(String businessId, Map<String, dynamic> serviceData) {
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
      'category_level_0_id': serviceData['category_level_0_id'] ?? '',
      'category_level_1_id': serviceData['category_level_1_id'] ?? '',
      'category_level_2_id': serviceData['category_level_2_id'], // Can be null for level 1 services
      'name': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'is_class': isClass,
      'is_archived': false,
      'tags': selectedTags,
      'media_url': '', // Placeholder URL
      'staff_ids': !isClass ? selectedStaffIds : [],
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
  final VoidCallback? onDelete;
  final List<Map<String, dynamic>>? staffMembers;
  final List<Map<String, dynamic>>? locations;
  
  const EnhancedServicesForm({
    super.key, 
    required this.serviceData,
    this.onDelete,
    this.staffMembers,
    this.locations,
  });

  @override
  State<EnhancedServicesForm> createState() => EnhancedServicesFormState();
}

class EnhancedServicesFormState extends State<EnhancedServicesForm> {
  final List<EnhancedServiceFormData> forms = [];
  
  // Get staff members from widget or use fallback
  List<Map<String, dynamic>> get staffMembers => widget.staffMembers ?? [];
  
  // Get locations from widget or use fallback
  List<Map<String, dynamic>> get locations => widget.locations ?? [
    {'id': '62c3f41e-1234-400a-b678-44e89102eddd', 'title': 'Main Studio'},
    {'id': 'loc2', 'title': 'Private Room'},
    {'id': 'loc3', 'title': 'Outdoor Area'},
  ];

  // Available tags
  final List<String> availableTags = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one form
    final newForm = EnhancedServiceFormData(
      serviceId: widget.serviceData['category_id'] ?? '',
      isClass: widget.serviceData['is_class'] ?? false,
    );
    
    // Add some default tags for testing
    newForm.selectedTags.addAll([]);
    
    // Add some default staff members for non-class services
    if (!newForm.isClass) {
      newForm.selectedStaffIds.addAll([
        'a7e12345-ffff-4f4f-bbbb-b16e9787ce12',
        'f1c98e12-abcd-4350-82bb-21412abc901a'
      ]);
    }
    
    forms.add(newForm);
    
    // Pre-fill the title with the service title
    forms.first.titleController.text = widget.serviceData['title'] ?? '';
  }

  @override
  void dispose() {
    for (var form in forms) {
      form.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic>? getServiceDetails() {
    List<Map<String, dynamic>> allDetails = [];
    for (var form in forms) {
      final details = form.toJson(widget.serviceData['business_id'] ?? '', widget.serviceData);
      if (details != null) {
        allDetails.add(details);
      }
    }
    return allDetails.isNotEmpty ? {'services': allDetails} : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loop through all forms (multiple service variants)
        for (var formData in forms) ...[
          const SizedBox(height: 12),
          
          // Service name section with delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Name your service',
                style: AppTypography.headingSm
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (forms.length > 1) {
                      forms.remove(formData);
                    } else if (widget.onDelete != null) {
                      widget.onDelete!();
                    }
                  });
                },
                child: Icon(
                  Icons.delete_outline,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8),
          InputField(
            hintText: 'Service title',
            controller: formData.titleController,
          ),
          
          SizedBox(height: 16),
          
          // Description section
          Text(
            'Write a short description',
            style: AppTypography.bodyMedium
          ),
          SizedBox(height: 8),
          InputField(
            hintText: 'Service description',
            controller: formData.descriptionController,
          ),
          
          SizedBox(height: 24),
          
          // Duration section
          Text(
            'Duration', 
            style: AppTypography.headingSm,
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
            style: AppTypography.headingSm
          ),
          SizedBox(height: 12),
          Column(
            children: formData.durationAndCosts
                .where((e) => e['duration'].toString().isNotEmpty)
                .map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        const SizedBox(height: 8),
                        Row(
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
                                    controller: item['packagePersonController'],
                                    onChanged: (val) => setState(() => item['packagePerson'] = val),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 88,
                                  child: NumericInputBox(
                                    hintText: "3200",
                                    controller: item['packageAmountController'],
                                    onChanged: (val) => setState(() => item['packageAmount'] = val),
                                  ),
                                ),
                              ],
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
            style: AppTypography.headingSm
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
              style: AppTypography.headingSm
            ),
            SizedBox(height: 8),
            DropDown(
              items: locations.map((location) => {
                'id': location['id']?.toString() ?? '',
                'name': location['title']?.toString() ?? location['name']?.toString() ?? 'Unknown Location',
              }).toList(),
              hintText: 'Choose location',
              onChanged: (selectedLocation) {
                setState(() {
                  formData.selectedLocationId = selectedLocation['id'] ?? '';
                  // Initialize controllers for each duration when location is selected
                  if (selectedLocation['id'] != null) {
                    for (var item in formData.durationAndCosts) {
                      if (item['duration'].toString().isNotEmpty) {
                        final key = '${selectedLocation['id']}_${item['duration']}';
                        formData.getLocationPriceController(key);
                      }
                    }
                  }
                });
              },
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
          if (!formData.isClass) ...[
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
                final staffId = staff['id']?.toString() ?? '';
                final isSelected = formData.selectedStaffIds.contains(staffId);
                final staffName = staff['name']?.toString() ?? 
                    staff['full_name']?.toString() ?? 
                    staff['first_name']?.toString() ?? 
                    'Unknown Staff';
                
                return CheckboxListItem(
                    title: staffName,
                    isSelected: isSelected,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          formData.selectedStaffIds.add(staffId);
                        } else {
                          formData.selectedStaffIds.remove(staffId);
                        }
                      });
                    },
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
          
          const SizedBox(height: 24),
        ],
        
        // Add new service button (works correctly for classes)
        SecondaryButton(
          onPressed: () {
            setState(() {
              final newForm = EnhancedServiceFormData(
                serviceId: widget.serviceData['category_id'] ?? '',
                isClass: widget.serviceData['is_class'] ?? false,
              );
              forms.add(newForm);
            });
          },
          prefix: Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          text: "Add new ${widget.serviceData['title'] ?? 'service'}",
        ),
      ],
    );
  }
}