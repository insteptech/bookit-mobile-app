import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';

class OnboardBusinessInfoForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController websiteController;
  const OnboardBusinessInfoForm({super.key, required this.nameController, required this.emailController, required this.mobileController, required this.websiteController});

  @override
  State<OnboardBusinessInfoForm> createState() => _OnboardBusinessInfoFormState();
}

class _OnboardBusinessInfoFormState extends State<OnboardBusinessInfoForm> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Business information", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),),
        SizedBox(height: 16),
        Text("Name", style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(hintText: "Name", controller: widget.nameController,),
        SizedBox(height: 16),
        Text("Email", style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(hintText: "Email", controller: widget.emailController),
        SizedBox(height: 16),
        Text("Mobile phone", style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(hintText: "Mobile", controller: widget.mobileController),
        SizedBox(height: 16),
        Text("Website (optional)", style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(hintText: "Website", controller: widget.websiteController),
      ],
    );
  }
}