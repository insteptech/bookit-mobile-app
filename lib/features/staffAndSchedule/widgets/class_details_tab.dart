import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/small_fixed_text_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/custom_switch.dart';
import '../application/add_edit_class_schedule_controller.dart';

class ClassDetailsTab extends StatelessWidget {
  const ClassDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddEditClassScheduleController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class image upload section
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile_picker_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/actions/share.svg',
                    width: 48,
                    height: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.smallContentSpacing),
                  Text(
                    'Upload picture',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.sectionSpacing),
            
            // Service dropdown (read-only display)
            Text(
              controller.serviceData?['title'] ?? controller.serviceData?['name'] ?? 'Service',
              style: AppTypography.headingMd,
            ),
            
            const SizedBox(height: AppConstants.contentSpacing),
            
            // Class title section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class title',
                  style: AppTypography.headingSm,
                ),
                Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.labelToFieldSpacing),
            
            InputField(
              hintText: 'Class title',
              controller: controller.titleController,
            ),
            
            const SizedBox(height: AppConstants.fieldToFieldSpacing),
            
            // Description section
            Text(
              'Write a short description',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: AppConstants.labelToFieldSpacing),
            
            InputField(
              hintText: 'Class description',
              controller: controller.descriptionController,
              maxLines: 3,
            ),
            
            const SizedBox(height: AppConstants.sectionSpacing),
            
            // Duration section
            Text(
              'Duration',
              style: AppTypography.headingSm,
            ),
            
            const SizedBox(height: AppConstants.contentSpacing),
            
            Row(
              children: [
                const SmallFixedTextBox(text: "minutes"),
                const SizedBox(width: AppConstants.smallContentSpacing),
                SizedBox(
                  width: 88,
                  child: NumericInputBox(
                    controller: controller.durationController,
                    hintText: '00',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.sectionSpacing),
            
            // Cost section
            Text(
              'Cost',
              style: AppTypography.headingSm,
            ),
            
            const SizedBox(height: AppConstants.contentSpacing),
            
            // Price per session row with label and inputs
            Row(
              children: [
                // Price per session label
                SizedBox(
                  width: 132,
                  child: Text(
                    'Price per session',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF202733),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallContentSpacing),
                // EGP currency box
                SizedBox(
                  width: 88,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCED4DA)),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x0D212529),
                          blurRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color(0x0F212529),
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'EGP',
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFF202733),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallContentSpacing),
                // Price input box
                SizedBox(
                  width: 88,
                  child: NumericInputBox(
                    controller: controller.priceController,
                    hintText: '000',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.smallContentSpacing),
            
            // Class pack row with label and inputs
            Row(
              children: [
                // Class pack label
                SizedBox(
                  width: 132,
                  child: Text(
                    'Class pack',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF202733),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallContentSpacing),
                // First input (X)
                SizedBox(
                  width: 88,
                  child: NumericInputBox(
                    controller: controller.packagePersonController,
                    hintText: 'X',
                  ),
                ),
                const SizedBox(width: AppConstants.smallContentSpacing),
                // Second input (000)
                SizedBox(
                  width: 88,
                  child: NumericInputBox(
                    controller: controller.packageAmountController,
                    hintText: '000',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.sectionSpacing),
            
            // Spots Available section
            Text(
              'Spots Available',
              style: AppTypography.headingSm,
            ),
            
            const SizedBox(height: AppConstants.smallContentSpacing),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set a limit on available spots',
                  style: AppTypography.bodyMedium,
                ),
                CustomSwitch(
                  value: controller.spotsLimitEnabled,
                  onChanged: (value) {
                    controller.setSpotsLimitEnabled(value);
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            
            if (controller.spotsLimitEnabled) ...[
              const SizedBox(height: AppConstants.contentSpacing),
              SizedBox(
                width: 88,
                child: NumericInputBox(
                  controller: controller.spotsController,
                  hintText: '10',
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}