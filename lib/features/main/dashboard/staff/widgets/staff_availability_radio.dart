import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/shared/components/molecules/radio_button_custom.dart';
import 'package:flutter/material.dart';

class StaffAvailabilityRadio extends StatefulWidget {
  final int index;
  final StaffScheduleController controller;

  const StaffAvailabilityRadio({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  State<StaffAvailabilityRadio> createState() => _StaffAvailabilityRadioState();
}

class _StaffAvailabilityRadioState extends State<StaffAvailabilityRadio> {
  @override
  Widget build(BuildContext context) {
    final availableText = AppTranslationsDelegate.of(context).text("available");
    final unavailableText = AppTranslationsDelegate.of(context).text("unavailable");
    
    return RadioButtonCustom(
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
    );
  }
}
