import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/application/staff_schedule_controller.dart';
import 'package:flutter/material.dart';

class LocationSelectorRadio extends StatefulWidget {
  final int index;
  final List<Map<String, String>> locations;
  final StaffScheduleController controller;
  final VoidCallback onChange;

  const LocationSelectorRadio({
    super.key,
    required this.index,
    required this.locations,
    required this.controller,
    required this.onChange,
  });

  @override
  State<LocationSelectorRadio> createState() => _LocationSelectorRadioState();
}


class _LocationSelectorRadioState extends State<LocationSelectorRadio> {
  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (widget.locations.isEmpty)
        const Center(child: Text(""))
      else ...[
        Text(
          AppTranslationsDelegate.of(context).text("choose_location"),
          style: AppTypography.headingSm,
        ),
        const SizedBox(height: 8),
        ...widget.locations.map((location) {
          final id = location['id']!;
          final title = location['title']!;
          final isSelected = widget.controller.entries[widget.index].locationId == id;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Radio<String>(
                  value: id,
                  groupValue: widget.controller.entries[widget.index].locationId,
                  onChanged: (value) {
  setState(() {
    widget.controller.updateLocation(widget.index, value!);
    widget.onChange(); // triggers setState in parent → causes all forms to rebuild
  });
},

                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                    return isSelected ? theme.colorScheme.primary : Colors.grey;
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: AppTypography.bodyMedium),
                ),
              ],
            ),
          );
        }),
      ],
    ],
  );
}

}
