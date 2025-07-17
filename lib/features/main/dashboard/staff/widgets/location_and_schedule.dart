import 'package:bookit_mobile_app/features/main/dashboard/staff/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/location_selector_radio.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/schedule_selector.dart';
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
      LocationSelectorRadio(
        index: widget.index,
        locations: widget.locations,
        controller: widget.controller,
        onChange: widget.onChange,
      ),
      const SizedBox(height: 18),
      ScheduleSelector(
  index: widget.index,
  controller: widget.controller,
),

    ],
  );
}

}