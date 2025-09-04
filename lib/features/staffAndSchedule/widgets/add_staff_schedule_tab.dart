import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/schedule_selector.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/custom_switch.dart';
import 'package:bookit_mobile_app/shared/components/molecules/multi_select_item.dart';
// import 'package:bookit_mobile_app/shared/components/molecules/radio_button_custom.dart';
import 'package:flutter/material.dart';

class AddStaffScheduleTab extends StatefulWidget {
  final List<Map<String, dynamic>>? services;
  final StaffScheduleController controller;
  final List<Map<String, dynamic>> category;
  final List<Map<String, dynamic>>? locations;
  final VoidCallback onChange;
  final VoidCallback onDelete;
  // Add parameters for state preservation
  final List<bool>? initialSelectedDays;
  final Map<int, dynamic>? initialTimeRanges;
  final List<dynamic>? initialSelectedLocations;
  final Function(List<bool>, Map<int, dynamic>, List<dynamic>)? onScheduleChanged;

  const AddStaffScheduleTab({
    super.key,
     this.services,
    required this.controller,
    this.locations,
  // locations removed
    required this.category,
    required this.onChange,
    required this.onDelete,
    this.initialSelectedDays,
    this.initialTimeRanges,
    this.initialSelectedLocations,
    this.onScheduleChanged,
  });

  @override
  State<AddStaffScheduleTab> createState() => _SetScheduleFormState();
}

class _SetScheduleFormState extends State<AddStaffScheduleTab> {
  bool showAllClasses = false;
  bool showAllServices = false;
  bool hasClasses = false;
  bool hasServices = false;
  List<Map<String, dynamic>> _apiServices = [];
  bool _isLoadingServices = false;
  String? _servicesError;

  void _fetchServices() async {
    if (widget.category.isEmpty) return;
    
    setState(() {
      _isLoadingServices = true;
      _servicesError = null;
    });
    
    try {
      // Get the category ID from the first category
      final categoryId = widget.category.first['id'];
      final response = await APIRepository.getServicesAndCategoriesOfBusiness(categoryId);
      
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> services = response.data['data']['services'] ?? [];
        _apiServices = [];
        
        // Extract serviceDetails from each business service
        for (var service in services) {
          final List<dynamic> serviceDetails = service['serviceDetails'] ?? [];
          for (var detail in serviceDetails) {
            final businessService = service['businessService'];
            final category = businessService['category'];
            _apiServices.add({
              'id': detail['id'],
              'name': detail['name'],
              'description': detail['description'],
              'isClass': category['is_class'] ?? false,
              'durations': detail['durations'] ?? [],
            });
          }
        }
      }
    } catch (e) {
      _servicesError = 'Failed to load services: $e';
    } finally {
      setState(() {
        _isLoadingServices = false;
      });
      _checkServiceTypes(); // Update service types after loading
    }
  }

  @override
  void initState() {
    super.initState();
    _checkServiceTypes();
    _fetchServices();
  }

  void _checkServiceTypes() {
    // Check the API services if available, otherwise fall back to categories
    if (_apiServices.isNotEmpty) {
      hasServices = _apiServices.any((service) => service['isClass'] == false);
      hasClasses = _apiServices.any((service) => service['isClass'] == true);
    } else {
      // Fallback to category-based logic
      final hasClassCategories = widget.category.any((cat) => cat['isClass'] == true);
      final hasServiceCategories = widget.category.any((cat) => cat['isClass'] == false);
      hasServices = hasServiceCategories;
      hasClasses = hasClassCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use API services if available, otherwise use empty list
    final allServices = _apiServices;
    
    // Services categorization
    final servicesOnly = allServices.where((service) => service['isClass'] == false).toList();
    final classesOnly = allServices.where((service) => service['isClass'] == true).toList();
    final visibleServices = showAllServices ? servicesOnly : servicesOnly.take(4).toList();
    final visibleClasses = showAllClasses ? classesOnly : classesOnly.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Staff availability",
              style: AppTypography.headingSm,
            ),
            CustomSwitch(
              value: widget.controller.schedule.isAvailable,
              onChanged: (val) {
                setState(() {
                  widget.controller.updateAvailability(val);
                });
                widget.onChange(); // Notify parent to update button state
              },
            ),
          ],
        ),

        const SizedBox(height: 8),
        if (!widget.controller.schedule.isAvailable)
        Text("Your staff is currently not visible to your clients. To allow bookings change their status to available, and fill in their schedule.", style: AppTypography.bodyMedium.copyWith(color: AppColors.error),),

        
        const SizedBox(height: 24),
        
        // Integrated ServicesOfferChecklistRow content - with opacity when unavailable
        if (_isLoadingServices) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 16),
        ] else if (_servicesError != null) ...[
          Text(
            _servicesError!,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 16),
        ] else if (hasServices) ...[
          Opacity(
            opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
            child: Text(
              "Services they offer",
              style: AppTypography.headingSm,
            ),
          ),
          Opacity(
            opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
            child: Column(
              children: [
                if (visibleServices.isEmpty)
                  const Center(child: Text("No services available"))
                else
                  ...visibleServices.map((service) {
                    final id = service['id']!;
                    final name = service['name']!;
                    final isSelected = widget.controller.schedule.selectedServices.contains(id);
                    return CheckboxListItem(
                      title: name,
                      isSelected: isSelected,
                      isDisabled: !widget.controller.schedule.isAvailable,
                      onChanged: (checked) {
                        if (widget.controller.schedule.isAvailable) {
                          setState(() {
                            widget.controller.toggleService(id);
                          });
                          widget.onChange(); // Notify parent to update button state
                        }
                      },
                    );
                  }),
              ],
            ),
          ),
          if (servicesOnly.length > 4) ...[
            const SizedBox(height: 8),
            Opacity(
              opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
              child: SecondaryButton(
                onPressed: widget.controller.schedule.isAvailable 
                  ? () {
                      setState(() {
                        showAllServices = !showAllServices;
                      });
                    }
                  : null, 
                text: showAllServices ? AppTranslationsDelegate.of(context).text("see_less") : AppTranslationsDelegate.of(context).text("see_all")
              ),
            ),
          ],
        ],

        if (hasClasses && hasServices) const SizedBox(height: 16),
        if (hasClasses) ...[
          Opacity(
            opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
            child: Text(
              "Classes they offer",
              style: AppTypography.headingSm,
            ),
          ),
          Opacity(
            opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
            child: Column(
              children: [
                if (visibleClasses.isEmpty)
                  const Center(child: Text("No classes available"))
                else
                  ...visibleClasses.map((service) {
                    final id = service['id']!;
                    final name = service['name']!;
                    final isSelected = widget.controller.schedule.selectedServices.contains(id);
                    return CheckboxListItem(
                      title: name,
                      isSelected: isSelected,
                      isDisabled: !widget.controller.schedule.isAvailable,
                      onChanged: (checked) {
                        if (widget.controller.schedule.isAvailable) {
                          setState(() {
                            widget.controller.toggleService(id);
                          });
                          widget.onChange(); // Notify parent to update button state
                        }
                      },
                    );
                  }),
              ],
            ),
          ),
          if (classesOnly.length > 4) ...[
            const SizedBox(height: 8),
            Opacity(
              opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
              child: SecondaryButton(
                onPressed: widget.controller.schedule.isAvailable 
                  ? () {
                      setState(() {
                        showAllClasses = !showAllClasses;
                      });
                    }
                  : null, 
                text: showAllClasses ? AppTranslationsDelegate.of(context).text("see_less") : AppTranslationsDelegate.of(context).text("see_all")
              ),
            ),
          ],
        ],
        
        const SizedBox(height: 24),
        
        // Integrated LocationAndSchedule content - with opacity when unavailable
        // Location selector removed
        const SizedBox(height: 18),
        Opacity(
          opacity: widget.controller.schedule.isAvailable ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: !widget.controller.schedule.isAvailable,
            child: ScheduleSelector(
              controller: widget.controller,
              dropdownContent: widget.locations,
              initialSelectedDays: widget.initialSelectedDays,
              initialTimeRanges: widget.initialTimeRanges,
              initialSelectedLocations: widget.initialSelectedLocations,
              onScheduleChanged: widget.onScheduleChanged,
              onScheduleUpdated: widget.onChange, // Notify parent when schedule changes
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}