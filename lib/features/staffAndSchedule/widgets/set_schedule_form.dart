import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/location_and_schedule.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/services_offer_checklist_row.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/staff_availability_radio.dart';
import 'package:flutter/material.dart';


class SetScheduleForm extends StatelessWidget {
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
  Widget build(BuildContext context) {

    final availableLocations = controller.getAvailableLocations(index, locations);

    final theme = Theme.of(context);

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
        if(index > 0)
       GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete, color: theme.colorScheme.error, size: 24),
            ),
          ],
        ),
        SizedBox(height: 8,),
        StaffAvailabilityRadio(
          index: index,
          controller: controller,
        ),
        SizedBox(height: 24,),
        ServicesOfferChecklistRow(
          index: index,
          services: category,
          controller: controller,
        ),
        SizedBox(height: 24,),


        LocationAndSchedule(
        index: index,
        locations: availableLocations, 
        controller: controller,
        onChange: onChange,
      ),
      
        const SizedBox(height: 24),
      ],
    );
  }
}
