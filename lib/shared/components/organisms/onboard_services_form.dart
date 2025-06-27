import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 🌐 Your imports here
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/organisms/onboard_scaffold_layout.dart';
import 'package:bookit_mobile_app/core/providers/business_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/numeric_input_box.dart';
import 'package:bookit_mobile_app/shared/components/atoms/small_fixed_text_box.dart';

// 🧠 Service Form Data
class ServiceFormData {
  final String serviceId;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
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

  Map<String, dynamic>? toJson(String businessId) {
    final durationList = durationAndCosts.where((item) {
      return item['duration'].toString().isNotEmpty && item['cost'].toString().isNotEmpty;
    }).map((item) {
      final map = {
        'duration_minutes': int.tryParse(item['duration'] ?? '0') ?? 0,
        'price': int.tryParse(item['cost'] ?? '0') ?? 0,
      };
      if ((item['packageAmount'] ?? '').isNotEmpty) {
        map['package_amount'] = int.tryParse(item['packageAmount']) ?? 0;
      }
      if ((item['packagePerson'] ?? '').isNotEmpty) {
        map['package_person'] = int.tryParse(item['packagePerson']) ?? 0;
      }
      return map;
    }).toList();

    if (titleController.text.trim().isEmpty || durationList.isEmpty) return null;

    return {
      'business_id': businessId,
      'service_id': serviceId,
      'name': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'durations': durationList,
    };
  }
}

// 🔧 Onboard Service Form
class OnboardServicesForm extends StatefulWidget {
  final String serviceId;
  const OnboardServicesForm({super.key, required this.serviceId});

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
          Text("Name your service", style: AppTypography.headingSm),
          const SizedBox(height: 8),
          InputField(
            hintText: "Service title",
            controller: formData.titleController,
          ),
          const SizedBox(height: 16),
          Text("Write a short description", style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          InputField(
            hintText: "Service description",
            controller: formData.descriptionController,
          ),
          const SizedBox(height: 16),
          Text("Duration", style: AppTypography.headingSm),
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
                            final isLast = i == formData.durationAndCosts.length - 1;
                            final hasEmpty = formData.durationAndCosts.any(
                              (e) => e['duration'].toString().isEmpty,
                            );
                            if (isLast && value.isNotEmpty && !hasEmpty) {
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
                            }
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
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text("Cost", style: AppTypography.headingSm),
          const SizedBox(height: 8),
          Column(
            children: formData.durationAndCosts
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
                        Text("${item['duration']} min", style: AppTypography.bodyMedium),
                        Row(
                          children: [
                            Text("EGP", style: AppTypography.bodyMedium),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 88,
                              child: NumericInputBox(
                                controller: item['costController'],
                                onChanged: (val) => setState(() => item['cost'] = val),
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
                        Text("Package", style: AppTypography.bodyMedium),
                        Row(
                          children: [
                            SizedBox(
                              width: 88,
                              child: NumericInputBox(
                                hintText: "10x",
                                controller: item['packagePersonController'],
                                onChanged: (val) => setState(() => item['packagePerson'] = val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 88,
                              child: NumericInputBox(
                                hintText: "3200",
                                controller: item['packageAmountController'],
                                onChanged: (val) => setState(() => item['packageAmount'] = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        GestureDetector(
          onTap: () {
            setState(() {
              forms.add(ServiceFormData(serviceId: widget.serviceId));
            });
          },
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded),
              const SizedBox(width: 4),
              Text(
                "Add another service",
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}