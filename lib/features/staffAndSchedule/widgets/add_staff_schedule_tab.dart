import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
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

  const AddStaffScheduleTab({
    super.key,
     this.services,
    required this.controller,
    this.locations,
  // locations removed
    required this.category,
    required this.onChange,
    required this.onDelete,
  });

  @override
  State<AddStaffScheduleTab> createState() => _SetScheduleFormState();
}

class _SetScheduleFormState extends State<AddStaffScheduleTab> {
  bool showAllClasses = false;
  bool showAllServices = false;
  bool hasClasses = false;
  bool hasServices = false;

  @override
  void initState() {
    super.initState();
    _checkServiceTypes();
  }

  void _checkServiceTypes() {
    for (int i = 0; i < widget.category.length; i++) {
      if (widget.category[i]['isClass'] == true) {
        hasClasses = true;
      }
      if (widget.category[i]['isClass'] == false) {
        hasServices = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  // Location selection removed
    final theme = Theme.of(context);

    // Services categorization
    final servicesOnly = widget.category.where((service) => service['isClass'] == false).toList();
    final classesOnly = widget.category.where((service) => service['isClass'] == true).toList();
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
          if (widget.category.isEmpty)
            const Center(child: Text(""))
          else
            ...visibleServices.map((service) {
              final id = service['id']!;
              final name = service['name']!;
              final isSelected = widget.controller.schedule.selectedServices.contains(id);
              return CheckboxListItem(
                title: name,
                isSelected: isSelected,
                onChanged: (checked) {
                  setState(() {
                    widget.controller.toggleService(id);
                  });
                },
              );
            }),
          if (servicesOnly.length > 4) ...[
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: () {
                setState(() {
                  showAllServices = !showAllServices;
                });
              }, 
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
          if (widget.category.isEmpty)
            const Center(child: Text(""))
          else
            ...visibleClasses.map((service) {
              final id = service['id']!;
              final name = service['name']!;
              final isSelected = widget.controller.schedule.selectedServices.contains(id);
              return CheckboxListItem(
                title: name,
                isSelected: isSelected,
                onChanged: (checked) {
                  setState(() {
                    widget.controller.toggleService(id);
                  });
                },
              );
            }),
          if (classesOnly.length > 4) ...[
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: () {
                setState(() {
                  showAllClasses = !showAllClasses;
                });
              }, 
              text: showAllClasses ? AppTranslationsDelegate.of(context).text("see_less") : AppTranslationsDelegate.of(context).text("see_all")
            ),
          ],
        ],
        
        const SizedBox(height: 24),
        
        // Integrated LocationAndSchedule content
        // Location selector removed
        const SizedBox(height: 18),
        ScheduleSelector(
          controller: widget.controller,
          dropdownContent: widget.locations
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}