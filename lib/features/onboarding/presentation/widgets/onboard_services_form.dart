import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/small_fixed_text_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/custom_switch.dart';
import 'package:bookit_mobile_app/features/onboarding/domain/domain.dart';
import 'package:bookit_mobile_app/shared/components/atoms/delete_action.dart';

class ServiceFormData {
  final String serviceId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool spotsAvailable = false;
  final TextEditingController spotsController = TextEditingController();
  final List<Map<String, dynamic>> durationAndCosts = [
    {
      "duration": "",
      "cost": "",
      "packageAmount": "",
      "packagePerson": "",
      "durationController": TextEditingController(),
      "costController": TextEditingController(),
      "packageAmountController": TextEditingController(),
      "packagePersonController": TextEditingController(),
    },
  ];

  ServiceFormData({required this.serviceId});

  /// Creates domain entity from form data - no business logic, just data conversion
  ServiceData? toServiceData() {
    return ServiceDataFactory.fromFormData(
      serviceId: serviceId,
      name: titleController.text,
      description: descriptionController.text,
      durationAndCosts: durationAndCosts,
      spotsAvailable: spotsAvailable,
      spotsText: spotsController.text,
    );
  }
}

class OnboardServicesForm extends StatefulWidget {
  final String serviceId;
  final bool isClass;
  const OnboardServicesForm({super.key, required this.serviceId, this.isClass = false});

  @override
  State<OnboardServicesForm> createState() => OnboardServicesFormState();
}

class OnboardServicesFormState extends State<OnboardServicesForm> {
  final List<ServiceFormData> forms = [];

  @override
  void initState() {
    super.initState();
    forms.add(ServiceFormData(serviceId: widget.serviceId));
  }

  List<ServiceFormData> getFormDataList() => forms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var formData in forms) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppTranslationsDelegate.of(context).text("name_your_service"), style: AppTypography.headingSm),
              DeleteAction(
                onConfirm: () {
                  setState(() {
                    forms.remove(formData);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 8),
          InputField(
            hintText: AppTranslationsDelegate.of(context).text("service_title"),
            controller: formData.titleController,
          ),
          const SizedBox(height: 16),
          Text(AppTranslationsDelegate.of(context).text("write_short_description"), style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          InputField(
            maxLines: 3,
            hintText: AppTranslationsDelegate.of(context).text("service_description"),
            controller: formData.descriptionController,
          ),
          const SizedBox(height: 16),
          Text(AppTranslationsDelegate.of(context).text("duration"), style: AppTypography.headingSm),
          const SizedBox(height: 8),
          Column(
            children: List.generate(formData.durationAndCosts.length, (i) {
              final item = formData.durationAndCosts[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SmallFixedTextBox(text: "minutes"),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 88,
                      child: NumericInputBox(
                        controller: item['durationController'],
                        onChanged: (value) {
                          setState(() {
                            item['duration'] = value;
                            if (value.isEmpty) {
                              item['costController']?.clear();
                              item['cost'] = "";
                              item['packageAmountController']?.clear();
                              item['packageAmount'] = "";
                              item['packagePersonController']?.clear();
                              item['packagePerson'] = "";
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    if(formData.durationAndCosts.length>1)
                      GestureDetector(
                      onTap: () {
                        setState(() {
                          if (formData.durationAndCosts.length > 1) {
                            formData.durationAndCosts.remove(item);
                          }
                        });
                      },
                      child: Icon(
                        Icons.remove_circle_outline,
                        size: 26,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          if (!widget.isClass) // Only show "Add new duration" for non-class services
            GestureDetector(
              child: Text(
                "Add new duration",
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              onTap: () {
                setState(() {
                  formData.durationAndCosts.add({
                    "duration": "",
                    "cost": "",
                    "packageAmount": "",
                    "packagePerson": "",
                    "durationController": TextEditingController(),
                    "costController": TextEditingController(),
                    "packageAmountController": TextEditingController(),
                    "packagePersonController": TextEditingController(),
                  });
                });
              },
            ),
          const SizedBox(height: 16),
          Text(AppTranslationsDelegate.of(context).text("cost"), style: AppTypography.headingSm),
          const SizedBox(height: 8),
          Column(
            children:
                formData.durationAndCosts
                    .where((e) => e['duration'].toString().isNotEmpty)
                    .map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item['duration']} min",
                                  style: AppTypography.bodyMedium,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "EGP",
                                      style: AppTypography.bodyMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 88,
                                      child: NumericInputBox(
                                        controller: item['costController'],
                                        onChanged:
                                            (val) => setState(
                                              () => item['cost'] = val,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppTranslationsDelegate.of(context).text("package"),
                                  style: AppTypography.bodyMedium,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 88,
                                      child: NumericInputBox(
                                        hintText: "10x",
                                        controller:
                                            item['packagePersonController'],
                                        onChanged:
                                            (val) => setState(
                                              () => item['packagePerson'] = val,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 88,
                                      child: NumericInputBox(
                                        hintText: "3200",
                                        controller:
                                            item['packageAmountController'],
                                        onChanged:
                                            (val) => setState(
                                              () => item['packageAmount'] = val,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
          ),
          if (widget.isClass) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Spots available",
                  style: AppTypography.headingSm,
                ),
                CustomSwitch(
                  value: formData.spotsAvailable,
                  onChanged: (value) {
                    setState(() {
                      formData.spotsAvailable = value;
                      if (!value) {
                        formData.spotsController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
            if (formData.spotsAvailable) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: NumericInputBox(
                      controller: formData.spotsController,
                      hintText: "00",
                      onChanged: (value) {
                        setState(() {
                          // Just trigger rebuild for any validation if needed
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 24),
        ],
        SecondaryButton(
          onPressed: () {
            setState(() {
              forms.add(ServiceFormData(serviceId: widget.serviceId));
            });
          },
          prefix: Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          text: "Add another service",
        ),
      ],
    );
  }
}
