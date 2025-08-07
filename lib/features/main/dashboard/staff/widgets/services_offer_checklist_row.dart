import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/molecules/multi_select_item.dart';
import 'package:flutter/material.dart';

class ServicesOfferChecklistRow extends StatefulWidget {
  final int index;
  final List<Map<String, dynamic>> services;
  final StaffScheduleController controller;

  const ServicesOfferChecklistRow({
    super.key,
    required this.index,
    required this.services,
    required this.controller,
  });

  @override
  State<ServicesOfferChecklistRow> createState() => _ServicesOfferChecklistRowState();
}

class _ServicesOfferChecklistRowState extends State<ServicesOfferChecklistRow> {
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
    for (int i = 0; i < widget.services.length; i++) {
      if (widget.services[i]['isClass'] == true) {
        hasClasses = true;
      }
      if (widget.services[i]['isClass'] == false) {
        hasServices = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesOnly = widget.services.where((service) => service['isClass'] == false).toList();
    final classesOnly = widget.services.where((service) => service['isClass'] == true).toList();
    final visibleServices = showAllServices ? servicesOnly : servicesOnly.take(4).toList();
    final visibleClasses = showAllClasses ? classesOnly : classesOnly.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasServices) ...[
          Text(
            "Services they offer",
            style: AppTypography.headingSm,
          ),
          if (widget.services.isEmpty)
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
          if (widget.services.isEmpty)
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

      ],
    );
  }
}
