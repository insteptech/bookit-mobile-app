import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/main/home/staff/application/staff_schedule_controller.dart';
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
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    isAvailable = widget.controller.entries[widget.index].isAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildRadioOption('Available', true),
        const SizedBox(width: 40),
        _buildRadioOption('Unavailable', false),
      ],
    );
  }

  Widget _buildRadioOption(String label, bool value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: isAvailable,
          activeColor: theme.colorScheme.primary,
          onChanged: (val) {
            setState(() {
              isAvailable = val!;
              widget.controller.entries[widget.index].isAvailable = isAvailable;
            });
          },
        ),
        Text(
          label,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}
