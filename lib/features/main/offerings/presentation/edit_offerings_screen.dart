import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/small_fixed_text_box.dart';
import 'package:bookit_mobile_app/features/main/offerings/controllers/edit_offerings_controller.dart';
import 'package:bookit_mobile_app/features/main/offerings/widgets/offerings_add_service_scaffold.dart';
import 'package:go_router/go_router.dart';

class EditOfferingsScreen extends StatefulWidget {
  final String serviceDetailId;

  const EditOfferingsScreen({
    super.key,
    required this.serviceDetailId,
  });

  @override
  State<EditOfferingsScreen> createState() => _EditOfferingsScreenState();
}

class _EditOfferingsScreenState extends State<EditOfferingsScreen> {
  late EditOfferingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditOfferingsController();
    _fetchServiceDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchServiceDetails() async {
    await _controller.fetchServiceDetails(widget.serviceDetailId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<EditOfferingsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${controller.errorMessage}',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        onPressed: _fetchServiceDetails,
                        text: 'Retry',
                        isHollow: true,
                        isDisabled: false,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return OfferingsAddServiceScaffold(
            title: controller.isClass ? 'Edit class' : 'Edit service',
            onBackPressed: () => context.pop(),
            body: _buildFormContent(controller),
            bottomButton: PrimaryButton(
              onPressed: controller.isSubmitting ? null : _handleSave,
              isDisabled: controller.isSubmitting,
              text: controller.isSubmitting ? 'Saving...' : 'Save',
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormContent(EditOfferingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Image (for classes)
        if (controller.isClass) ...[
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: const DecorationImage(
                image: NetworkImage(
                  "https://dims.apnews.com/dims4/default/e40c94b/2147483647/strip/true/crop/7773x5182+0+0/resize/599x399!/quality/90/?url=https%3A%2F%2Fassets.apnews.com%2F16%2Fc9%2F0eecec78d44f016ffae1915e26c3%2F304c692a6f0b431aa8f954a4fdb5d7b5",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Class/Service Title
        Text(
          controller.isClass ? 'Class title' : 'Service title',
          style: AppTypography.headingSm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InputField(
          hintText: controller.isClass 
              ? 'Enter class title' 
              : 'Enter service title',
          controller: controller.titleController,
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'Write a short description',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InputField(
          hintText: 'Enter description',
          controller: controller.descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // Duration Section
        Text(
          'Duration',
          style: AppTypography.headingSm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Duration inputs
        Column(
          children: List.generate(
            controller.durations.length,
            (index) => _buildDurationRow(controller, index),
          ),
        ),
        
        // Add duration button
        if(!controller.isClass)
        GestureDetector(
          onTap: controller.addDuration,
          child: Text(
            "Add new duration",
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Cost Section
        Text(
          'Cost',
          style: AppTypography.headingSm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Price per session',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Cost inputs
        Column(
          children: controller.durations
              .asMap()
              .entries
              .where((entry) => entry.value.durationController.text.isNotEmpty)
              .map((entry) => _buildCostRow(controller, entry.key))
              .toList(),
        ),
        const SizedBox(height: 24),

        // Spots Available (for classes)
        if (controller.isClass) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spots Available',
                style: AppTypography.headingSm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: controller.spotsLimitEnabled,
                onChanged: (value) {
                  controller.setSpotsLimitEnabled(value);
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          if (controller.spotsLimitEnabled) ...[
            const SizedBox(height: 8),
            Text(
              'Set a limit on available spots',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              child: NumericInputBox(
                controller: controller.spotsController,
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDurationRow(EditOfferingsController controller, int index) {
    final duration = controller.durations[index];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SmallFixedTextBox(text: "minutes"),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            child: NumericInputBox(
              controller: duration.durationController,
              onChanged: (value) {
                controller.updateDuration(index, value);
              },
            ),
          ),
          const SizedBox(width: 8),
          if (controller.durations.length > 1)
            GestureDetector(
              onTap: () => controller.removeDuration(index),
              child: Icon(
                Icons.remove_circle_outline,
                size: 26,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCostRow(EditOfferingsController controller, int index) {
    final duration = controller.durations[index];
    final durationText = duration.durationController.text;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price per session
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$durationText min",
                style: AppTypography.bodyMedium,
              ),
              Row(
                children: [
                  const Text(
                    "EGP",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 88,
                    child: NumericInputBox(
                      controller: duration.priceController,
                      onChanged: (value) {
                        controller.updatePrice(index, value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Package pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Class pack",
                style: AppTypography.bodyMedium,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: NumericInputBox(
                      hintText: "10x",
                      controller: duration.packagePersonController,
                      onChanged: (value) {
                        controller.updatePackagePerson(index, value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 88,
                    child: NumericInputBox(
                      hintText: "4000",
                      controller: duration.packageAmountController,
                      onChanged: (value) {
                        controller.updatePackageAmount(index, value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final success = await _controller.saveChanges();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Failed to save changes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
