import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/home/staff/application/staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/main/home/staff/widgets/set_schedule_form.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddStaffScheduleScreen extends StatefulWidget {
  final String staffId;
  const AddStaffScheduleScreen({super.key, required this.staffId});

  @override
  State<AddStaffScheduleScreen> createState() => _AddStaffScheduleScreenState();
}

class _AddStaffScheduleScreenState extends State<AddStaffScheduleScreen> {
  List<Map<String, String>> category = [];
  List<Map<String, String>> locations = [];
  String userName = "";
  final StaffScheduleController controller = StaffScheduleController();

  Future<void> getDetails() async {
    final data = await APIRepository.getStaffUserDetails(widget.staffId);
    final List<dynamic> categoriesJson =
        data.data['data']['schedule']['data']['category'];
    final List<dynamic> locationJson =
        data.data['data']['schedule']['data']['locations'];

    setState(() {
      category =
          categoriesJson
              .map(
                (cat) => {
                  'id': cat['id'].toString(),
                  'name': cat['name'].toString(),
                },
              )
              .toList();

      locations =
          locationJson
              .map(
                (loc) => {
                  'id': loc['id'].toString(),
                  'title': loc['title'].toString(),
                },
              )
              .toList();

      userName = data.data['data']['schedule']['data']['name'] ?? "";

      controller.entries.clear(); // Clear if already had dummy entry

      for (var loc in locationJson) {
        if (loc['is_selected'] == true) {
          final entry = LocationScheduleEntry(
            locationId: loc['id'],
            isAvailable: true, 
          );

          // Set selected services
          for (var cat in categoriesJson) {
            if (cat['is_selected'] == true) {
              entry.selectedServices.add(cat['id']);
            }
          }

          // Set schedule
          final List<Map<String, String>> parsedSchedule = [];
          for (var schedule in loc['days_schedule']) {
            if (schedule['is_selected'] == true) {
              parsedSchedule.add({
                'day': schedule['day'],
                'from': schedule['from'],
                'to': schedule['to'],
              });
            }
          }

          entry.daySchedules = parsedSchedule;
          controller.entries.add(entry);
        }
      }

      // If no selected entry, still add 1 for UI
      if (controller.entries.isEmpty) {
        controller.addNewEntry();
      }
    });
  }

  Future<void> saveUserSchedule() async {
    final payload = controller.buildFinalPayload();
    try {
      await APIRepository.postStaffUserDetails(
        id: widget.staffId,
        payload: payload,
      );
      if (mounted) {
        context.go('/home_screen');
      }
    } catch (e) {
      throw Exception("Failed to save staff schedule: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    getDetails();
    // controller.addNewEntry(); // add first form by default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 32),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          "Set schedule",
                          style: AppTypography.headingLg,
                        ),
                        const SizedBox(height: 40),
                        Text(userName, style: AppTypography.headingMd),
                        const SizedBox(height: 24),
                        ...List.generate(controller.entries.length, (index) {
                          return SetScheduleForm(
                            index: index,
                            services: category,
                            controller: controller,
                            locations: locations,
                            category: category,
                            onChange: () => setState(() {}),
                            onDelete: () {
                              setState(() {
                                controller.removeEntry(index);
                              });
                            },
                          );
                        }),

                        if (controller.entries.length < locations.length)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                controller.addNewEntry();
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 22,
                            ),
                            label: const Text('Add another location schedule'),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    children: [
                      PrimaryButton(
                        text: "Continue to schedule",
                        onPressed: () {
                          saveUserSchedule();
                        },
                        isDisabled: false,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go("/home_screen"),
                          child: Text(
                            "Save & exit",
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
