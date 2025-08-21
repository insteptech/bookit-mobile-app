import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/services/staff_service.dart';
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

  void _fetchServices() async {
    try {
      await APIRepository.getBusinessServiceCategories();
      // This is a placeholder for future implementation
      // Services are now provided by the dummy service
    } catch (e) {
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _checkServiceTypes();
    _fetchServices();
  }

  void _checkServiceTypes() {
    // Check the filtered services instead of categories
    final allServices = StaffService.getAllDummyServices();
    final hasClassCategories = widget.category.any((cat) => cat['isClass'] == true);
    final hasServiceCategories = widget.category.any((cat) => cat['isClass'] == false);
    
    List<Map<String, dynamic>> filteredServices = allServices;
    
    if (hasClassCategories && !hasServiceCategories) {
      filteredServices = allServices.where((service) => service['isClass'] == true).toList();
    } else if (hasServiceCategories && !hasClassCategories) {
      filteredServices = allServices.where((service) => service['isClass'] == false).toList();
    }

    hasServices = filteredServices.any((service) => service['isClass'] == false);
    hasClasses = filteredServices.any((service) => service['isClass'] == true);
  }

  @override
  Widget build(BuildContext context) {

    // For now, use the existing category approach but with filtered services from our dummy data
    // In future, this should be replaced with actual API call that filters services by category
    final allServices = StaffService.getAllDummyServices();
    
    // Filter services to match the type indicated by widget.category
    // For simplicity, if we have categories marked as classes, show class services, otherwise show massage services
    final hasClassCategories = widget.category.any((cat) => cat['isClass'] == true);
    final hasServiceCategories = widget.category.any((cat) => cat['isClass'] == false);
    
    List<Map<String, dynamic>> filteredServices = allServices;
    
    if (hasClassCategories && !hasServiceCategories) {
      // Only show class services
      filteredServices = allServices.where((service) => service['isClass'] == true).toList();
    } else if (hasServiceCategories && !hasClassCategories) {
      // Only show regular services
      filteredServices = allServices.where((service) => service['isClass'] == false).toList();
    }

    // Services categorization
    final servicesOnly = filteredServices.where((service) => service['isClass'] == false).toList();
    final classesOnly = filteredServices.where((service) => service['isClass'] == true).toList();
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
        
        // Integrated ServicesOfferChecklistRow content
        if (hasServices) ...[
          Text(
            "Services they offer",
            style: AppTypography.headingSm,
          ),
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
          if (servicesOnly.length > 4) ...[
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: widget.controller.schedule.isAvailable 
                ? () {
                    setState(() {
                      showAllServices = !showAllServices;
                    });
                  }
                : null, 
              text: showAllServices ? AppTranslationsDelegate.of(context).text("see_less") : AppTranslationsDelegate.of(context).text("see_all")
            ),
          ],
        ],

        if (hasClasses && hasServices) const SizedBox(height: 16),
        if (hasClasses) ...[
          Text(
            "Classes they offer",
            style: AppTypography.headingSm,
          ),
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
          if (classesOnly.length > 4) ...[
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: widget.controller.schedule.isAvailable 
                ? () {
                    setState(() {
                      showAllClasses = !showAllClasses;
                    });
                  }
                : null, 
              text: showAllClasses ? AppTranslationsDelegate.of(context).text("see_less") : AppTranslationsDelegate.of(context).text("see_all")
            ),
          ],
        ],
        
        const SizedBox(height: 24),
        
        // Integrated LocationAndSchedule content
        // Location selector removed
        const SizedBox(height: 18),
        IgnorePointer(
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
        const SizedBox(height: 24),
      ],
    );
  }
}