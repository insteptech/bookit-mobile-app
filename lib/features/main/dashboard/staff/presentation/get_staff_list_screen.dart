import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/widgets/staff_member_row.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GetStaffListScreen extends StatefulWidget {
  const GetStaffListScreen({super.key});

  @override
  State<GetStaffListScreen> createState() => _GetStaffListScreen();
}

class _GetStaffListScreen extends State<GetStaffListScreen> {
  List<dynamic> staffMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffMembers();
  }

  Future<void> fetchStaffMembers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await APIRepository.getStaffList();
      final profiles = response.data['data']['profiles'] as List<dynamic>;

      if (mounted) {
        setState(() {
          staffMembers = profiles;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
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
                          onTap: () => context.go('/home_screen'),
                          child: const Icon(Icons.arrow_back, size: 32),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          "Set schedule",
                          style: AppTypography.headingLg,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Fantastic! Now, let's get their schedules sorted. You can add their availability here, and it's always editable under 'Schedule'. Choose a member to edit their schedule.",
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: 40),

                        /// Loading or No Staff or Staff List
                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (staffMembers.isEmpty)
                          const Center(child: Text("No staff created yet."))
                        else
                          ...staffMembers.map(
                            (member) => StaffMemberRow(
                              staffName: member['name'] ?? 'Unknown',
                              staffId: member['id'] ?? '0',
                              staffImageUrl: member['profile_photo_url'] ?? '',
                              onClick: () {
                                context.push(
                                  "/set_schedule",
                                  extra: {
                                    'staffId': member['id'],
                                    'staffName': member['name'],
                                  },
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 40),
                        TextButton.icon(
                          onPressed: () {
                            context.push("/add_staff");
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          label: const Text('Add Another Member'),
                        ),
                        const SizedBox(height: 24),
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
                        onPressed: () {},
                        isDisabled: false,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
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
