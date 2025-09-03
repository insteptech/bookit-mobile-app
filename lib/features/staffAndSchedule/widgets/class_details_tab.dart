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
import 'package:bookit_mobile_app/shared/components/atoms/warning_dialog.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import '../application/add_edit_class_schedule_controller.dart';

class ClassDetailsTab extends StatelessWidget {
  final bool isEditing;
  final String? classId;
  final String? className;
  
  const ClassDetailsTab({
    super.key,
    this.isEditing = false,
    this.classId,
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AddEditClassScheduleController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class image upload section
            GestureDetector(
              onTap: () => _showImagePickerOptions(context, controller),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: controller.selectedImage != null
                      ? DecorationImage(
                          image: FileImage(controller.selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage(
                            'assets/images/profile_picker_background.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
                child: controller.selectedImage != null
                    ? Stack(
                        children: [
                          // Overlay with remove button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
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
            ),

            const SizedBox(height: AppConstants.sectionSpacing),

            // Service dropdown (read-only display)
            if(controller.serviceData?['title'] != null)
            Text(
              controller.serviceData?['title'] ??
                  controller.serviceData?['name'] ??
                  'Service',
              style: AppTypography.headingMd,
            ),

            const SizedBox(height: AppConstants.contentSpacing),

            // Class title section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Class title', style: AppTypography.headingSm),
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
            Text('Duration', style: AppTypography.headingSm),

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
            Text('Cost', style: AppTypography.headingSm),

            const SizedBox(height: AppConstants.contentSpacing),

            // Price per session row with label and inputs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price per session label
                SizedBox(
                  width: 132,
                  child: Text(
                    'Price per session',
                    style: AppTypography.bodyMedium,
                  ),
                ),
                const SizedBox(width: AppConstants.smallContentSpacing),
                // EGP currency box
                Row(
                  children: [
                    SmallFixedTextBox(text: "EGP"),
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
              ],
            ),

            const SizedBox(height: AppConstants.smallContentSpacing),

            // Class pack row with label and inputs
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                // Class pack label
                SizedBox(
                  width: 132,
                  child: Text('Class pack', style: AppTypography.bodyMedium),
                ),
                const SizedBox(width: AppConstants.smallContentSpacing),
                // First input (X)
                Row(
                  children: [
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
                )
              ],
            ),

            const SizedBox(height: AppConstants.sectionSpacing),

            // Spots Available section
            Text('Spots Available', style: AppTypography.headingSm),

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

            // Delete button - only show when editing
            if (isEditing && classId != null) ...[
              const SizedBox(height: AppConstants.sectionSpacing),
              GestureDetector(
                onTap: () => _handleDeleteClass(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/actions/trash_medium.svg',
                      width: 18,
                      height: 18,
                      color: const Color(0xFFEA52E7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Delete class',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEA52E7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteClass(BuildContext context) async {
    if (classId == null) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return WarningDialog.confirmation(
          title: 'Delete ${className ?? 'Class'}',
          message: 'Are you sure you want to delete this class? This action cannot be undone.',
          actionText: 'Delete',
          actionButtonColor: Colors.transparent,
          actionTextColor: const Color(0xFFEA52E7),
          onConfirm: () {}, // Dialog handles the navigation
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await _deleteClass(context);
    }
  }

  Future<void> _deleteClass(BuildContext context) async {
    if (classId == null) return;

    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Deleting class...'),
              ],
            ),
            backgroundColor: Color(0xFFEA52E7),
          ),
        );
      }

      // Call the delete API
      final response = await APIRepository.deleteClass(classId!);

      if (context.mounted) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.data['data']['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Class deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );


          // Navigate back to dashboard
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete class. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting class: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions(BuildContext context, AddEditClassScheduleController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImageFromCamera();
                },
              ),
              if (controller.selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    controller.removeImage();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
