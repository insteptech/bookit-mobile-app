import 'package:bookit_mobile_app/shared/components/molecules/radio_button_custom.dart';
import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final VoidCallback? onSelectionChanged;
  final String? initialValue;

  const GenderSelector({super.key, this.onSelectionChanged, this.initialValue});

  @override
  State<GenderSelector> createState() => GenderSelectorState();
}

class GenderSelectorState extends State<GenderSelector> {
  String? selectedGender;

  /// Public getter for selected gender
  String? get selectedGenderValue => selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return RadioButtonCustom(
      options: const ["female", "male"],
      initialValue: selectedGender,
      onChanged: (value) {
        setState(() => selectedGender = value);
        widget.onSelectionChanged?.call();
      },
    );
  }
}
