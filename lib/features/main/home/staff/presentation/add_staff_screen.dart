import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/home/staff/models/staff_profile_request_model.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/add_member_form.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  List<int> memberForms = [0];
  Map<int, StaffProfile> staffProfiles = {};
  bool isLoading = false;

  void addMemberForm() {
    setState(() {
      memberForms.add(DateTime.now().millisecondsSinceEpoch);
    });
  }

  void removeMemberForm(int id) {
    if (memberForms.length <= 1) return;

    setState(() {
      memberForms.remove(id);
      staffProfiles.remove(id);
    });
  }

  void updateStaffProfile(int id, StaffProfile profile) {
    setState(() {
      staffProfiles[id] = profile;
    });
  }

  bool get canSubmit {
    return staffProfiles.length == memberForms.length &&
        staffProfiles.values.every(
          (profile) =>
              profile.name.isNotEmpty &&
              profile.email.isNotEmpty &&
              profile.phoneNumber.isNotEmpty &&
              profile.categoryId.isNotEmpty &&
              profile.locationIds.isNotEmpty,
        );
  }

  Future<void> submitStaffProfiles() async {
    if (!canSubmit) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await APIRepository.addMultipleStaff(
        staffProfiles: staffProfiles.values.toList(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff members added successfully!')),
        );
        
        // Navigator.pop(context);
        context.push("/staff_list");
      } else {
        throw Exception('Failed to add staff members');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 32),
              ),
              const SizedBox(height: 9),
              const Text("Add staff", style: AppTypography.headingLg),
              const SizedBox(height: 48),

              // Render all member forms
              ...memberForms.map(
                (id) => Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AddMemberForm(
                    key: ValueKey(id),
                    onAdd: addMemberForm,
                    onDelete:
                        memberForms.length > 1
                            ? () => removeMemberForm(id)
                            : null,
                    onDataChanged: (profile) => updateStaffProfile(id, profile),
                  ),
                ),
              ),
              
              TextButton.icon(
                onPressed: addMemberForm,
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: const Text('Add Another Staff Member'),
              ),

              // Action buttons
              const SizedBox(height: 24),
              PrimaryButton(
                text: isLoading ? "Adding Staff..." : "Continue to schedule",
                onPressed: isLoading ? null : submitStaffProfiles,
                isDisabled: !canSubmit || isLoading,
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
            ],
          ),
        ),
      ),
    );
  }
}
