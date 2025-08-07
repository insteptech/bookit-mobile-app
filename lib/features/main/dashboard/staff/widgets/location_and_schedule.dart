import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/schedule_selector.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button_custom.dart';
import 'package:flutter/material.dart';

class LocationAndSchedule extends StatefulWidget {
  final int index;
  final List<Map<String, String>> locations;
  final StaffScheduleController controller;
  final VoidCallback onChange;


  const LocationAndSchedule({
    super.key,
    required this.index,
    required this.locations,
    required this.controller,
    required this.onChange,
  });

  @override
  State<LocationAndSchedule> createState() => _LocationAndScheduleState();
}
class _LocationAndScheduleState extends State<LocationAndSchedule> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.locations.isNotEmpty) ...[
          Text(
            AppTranslationsDelegate.of(context).text("choose_location"),
            style: AppTypography.headingSm,
          ),
          const SizedBox(height: 8),
          RadioButtonCustom(
            options: widget.locations.map((location) => location['title']!).toList(),
            initialValue: widget.locations
                .firstWhere(
                  (location) => location['id'] == widget.controller.entries[widget.index].locationId,
                  orElse: () => {'title': ''},
                )['title'],
            onChanged: (selectedTitle) {
              final selectedLocation = widget.locations.firstWhere(
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
      ],
    );
  }
}