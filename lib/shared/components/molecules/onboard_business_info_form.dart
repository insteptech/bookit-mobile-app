import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';

class OnboardBusinessInfoForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final TextEditingController websiteController;
  final bool? isDisabled;
  final bool? showHeading;
  const OnboardBusinessInfoForm({super.key, required this.nameController, required this.emailController, required this.mobileController, required this.websiteController, this.isDisabled, this.showHeading});

  @override
  State<OnboardBusinessInfoForm> createState() => _OnboardBusinessInfoFormState();
}

class _OnboardBusinessInfoFormState extends State<OnboardBusinessInfoForm> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeading ?? true)
          Text(
            AppTranslationsDelegate.of(context).text("business_information"),
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)
          ),
        // Text(AppTranslationsDelegate.of(context).text("business_information"), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),),
        SizedBox(height: 16),
        Text(AppTranslationsDelegate.of(context).text("name"), style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(
          hintText: "Business name", 
          controller: widget.nameController,
          isDisabled: widget.isDisabled,
        ),
        SizedBox(height: 16),
        Text(AppTranslationsDelegate.of(context).text("email"), style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(
          hintText: "youremail@business.com", 
          controller: widget.emailController,
          isDisabled: widget.isDisabled,
        ),
        SizedBox(height: 16),
        Text(AppTranslationsDelegate.of(context).text("mobile_phone"), style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(
          hintText: "Your business number", 
          controller: widget.mobileController,
          isDisabled: widget.isDisabled,
        ),
        SizedBox(height: 16),
        Text(AppTranslationsDelegate.of(context).text("website_optional"), style: AppTypography.bodyMedium,),
        SizedBox(height: 8,),
        InputField(
          hintText: "URL website", 
          controller: widget.websiteController,
          isDisabled: widget.isDisabled,
        ),
      ],
    );
  }
}