import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';

class OnboardingLocationInfoForm extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;
  final TextEditingController floorController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController instructionController;

  const OnboardingLocationInfoForm({
    super.key,
    required this.locationController,
    required this.addressController,
    required this.cityController,
    required this.floorController,
    required this.instructionController,
    required this.countryController,
    required this.stateController
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Address", style: AppTypography.bodyMedium),
        SizedBox(height: 16),
        SizedBox(height: 200, width: double.infinity, child: Container(color: Colors.amberAccent)),

        SizedBox(height: 16),
        Text("Location name", style: AppTypography.bodyMedium),
        InputField(hintText: "Location name", controller: locationController),

        SizedBox(height: 8),
        Text("Address", style: AppTypography.bodyMedium),
        InputField(hintText: "Street", controller: addressController),

        SizedBox(height: 8),
        Text("Floor / Apt", style: AppTypography.bodyMedium),
        InputField(hintText: "Floor, Apt. number", controller: floorController),

        SizedBox(height: 8),
        Text("City", style: AppTypography.bodyMedium),
        InputField(hintText: "City", controller: cityController),

        SizedBox(height: 8),
        Text("State", style: AppTypography.bodyMedium),
        InputField(hintText: "City", controller: stateController,),

        SizedBox(height: 8),
        Text("Country", style: AppTypography.bodyMedium),
        InputField(hintText: "Country", controller: countryController),

        SizedBox(height: 8),
        Text("Additional instructions", style: AppTypography.bodyMedium),
        InputField(hintText: "Directions and instructions", controller: instructionController),
      ],
    );
  }
}
