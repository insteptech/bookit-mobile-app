import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/schedule_selector.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/multi_select_item.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button_custom.dart';
import 'package:flutter/material.dart';

class SetScheduleForm extends StatefulWidget {
  final int index;
  final List<Map<String, dynamic>> services;
  final StaffScheduleController controller;
  final List<Map<String, String>> locations;
  final List<Map<String, dynamic>> category;
  final VoidCallback onChange;
  final VoidCallback onDelete;

  const SetScheduleForm({
    super.key,
    required this.index,
    required this.services,
    required this.controller,
    required this.locations,
    required this.category,
    required this.onChange,
    required this.onDelete,
  });

  @override
  State<SetScheduleForm> createState() => _SetScheduleFormState();
}

class _SetScheduleFormState extends State<SetScheduleForm> {
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
    final availableLocations = widget.controller.getAvailableLocations(widget.index, widget.locations);
    final theme = Theme.of(context);
    
    // Staff availability texts
    final availableText = AppTranslationsDelegate.of(context).text("available");
    final unavailableText = AppTranslationsDelegate.of(context).text("unavailable");

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
              "Show staff as",
              style: AppTypography.headingSm,
            ),
            if (widget.index > 0)
              GestureDetector(
                onTap: widget.onDelete,
                child: Icon(Icons.delete, color: theme.colorScheme.error, size: 24),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Integrated StaffAvailabilityRadio content
        RadioButtonCustom(
          options: [availableText, unavailableText],
          initialValue: widget.controller.entries[widget.index].isAvailable 
              ? availableText
              : unavailableText,
          onChanged: (value) {
            setState(() {
              widget.controller.entries[widget.index].isAvailable = 
                  value == availableText;
            });
          },
        ),
        
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
              final isSelected = widget.controller.entries[widget.index].selectedServices.contains(id);
              return CheckboxListItem(
                title: name,
                isSelected: isSelected,
                onChanged: (checked) {
                  setState(() {
                    widget.controller.toggleService(widget.index, id);
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
              final isSelected = widget.controller.entries[widget.index].selectedServices.contains(id);
              return CheckboxListItem(
                title: name,
                isSelected: isSelected,
                onChanged: (checked) {
                  setState(() {
                    widget.controller.toggleService(widget.index, id);
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
        if (availableLocations.isNotEmpty) ...[
          Text(
            AppTranslationsDelegate.of(context).text("choose_location"),
            style: AppTypography.headingSm,
          ),
          const SizedBox(height: 8),
          RadioButtonCustom(
            options: availableLocations.map((location) => location['title']!).toList(),
            initialValue: availableLocations
                .firstWhere(
                  (location) => location['id'] == widget.controller.entries[widget.index].locationId,
                  orElse: () => {'title': ''},
                )['title'],
            onChanged: (selectedTitle) {
              final selectedLocation = availableLocations.firstWhere(
                (location) => location['title'] == selectedTitle,
              );
              setState(() {
                widget.controller.updateLocation(widget.index, selectedLocation['id']!);
                widget.onChange();
              });
            },
            isHorizontal: false,
          ),
        ],
        const SizedBox(height: 18),
        ScheduleSelector(
          index: widget.index,
          controller: widget.controller,
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }
}