import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/navigation_service.dart';
import 'package:bookit_mobile_app/features/main/dashboard/staff/application/add_staff_controller.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:flutter/material.dart';
import '../widgets/add_member_form.dart';

enum StaffScreenButtonMode {
  continueToSchedule, 
  saveOnly,         
}

class AddStaffScreen extends StatefulWidget {
  final bool? isClass; 
  final StaffScreenButtonMode buttonMode;
  
  const AddStaffScreen({
    super.key, 
    this.isClass, 
    this.buttonMode = StaffScreenButtonMode.continueToSchedule, // Default mode
  });

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  late final AddStaffController _controller;
  bool _isSaveAndExit = false; // Track which action triggered the submission

  @override
  void initState() {
    super.initState();
    _controller = AddStaffController();
    _controller.setCallbacks(
      onStateChanged: () => setState(() {}),
      onSuccess: _handleSuccess,
      onError: _handleError,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    
    // Handle navigation based on which action was triggered
    if (_isSaveAndExit) {
      // For save and exit, just go back to previous screen
      Navigator.pop(context);
    } else {
      // For continue to schedule, handle navigation based on button mode
      if (widget.buttonMode == StaffScreenButtonMode.continueToSchedule) {
        // Navigate based on whether this is for a class or regular staff
        if (widget.isClass == true) {
          NavigationService.push("/add_class_schedule");
        } else {
          NavigationService.pushStaffList();
        }
      } else {
        // For saveOnly mode, just go back
        Navigator.pop(context);
      }
    }
    
    // Reset the flag
    _isSaveAndExit = false;
  }

  void _handleSaveAndExit() async {
    // Only save if there's valid data to save
    if (_controller.canSubmit) {
      _isSaveAndExit = true;
      await _controller.submitStaffProfiles();
      // Navigation will be handled by _handleSuccess callback
    } else {
      // If no valid data, just exit
      Navigator.pop(context);
    }
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppTranslationsDelegate.of(context).text("error")}: $error')),
    );
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
              Text(
                  AppTranslationsDelegate.of(context).text("add_staff"), 
                style: AppTypography.headingLg
              ),
              const SizedBox(height: 48),
              // Render all member forms
              ..._controller.memberForms.map(
                (id) => Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AddMemberForm(
                    key: ValueKey(id),
                    isClass: widget.isClass, // Pass the optional isClass parameter directly
                    onAdd: _controller.addMemberForm,
                    onDelete:
                        _controller.memberForms.length > 1
                            ? () => _controller.removeMemberForm(id)
                            : null,
                    onDataChanged: (profile) => _controller.updateStaffProfile(id, profile),
                  ),
                ),
              ),
              SecondaryButton(
                onPressed: _controller.addMemberForm, 
                text: AppTranslationsDelegate.of(context).text("add_another_staff_member"),
                prefix: Icon(Icons.add_circle_outline, size: 22, color: Theme.of(context).colorScheme.primary),
              ),

              // Action buttons
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (widget.buttonMode) {
      case StaffScreenButtonMode.continueToSchedule:
        return Column(
          children: [
            PrimaryButton(
              text: _controller.isLoading 
                ? AppTranslationsDelegate.of(context).text("adding_staff")
                : AppTranslationsDelegate.of(context).text("continue_to_schedule_text"),
              onPressed: _controller.isLoading ? null : _controller.submitStaffProfiles,
              isDisabled: !_controller.canSubmit || _controller.isLoading,
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _controller.isLoading ? null : _handleSaveAndExit,
                child: Text(
                  AppTranslationsDelegate.of(context).text("save_and_exit"),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _controller.isLoading ? Colors.grey : null,
                  ),
                ),
              ),
            ),
          ],
        );
      case StaffScreenButtonMode.saveOnly:
        return PrimaryButton(
          text: _controller.isLoading 
            ? AppTranslationsDelegate.of(context).text("adding_staff")
            : "Save",
          onPressed: _controller.isLoading ? null : _controller.submitStaffProfiles,
          isDisabled: !_controller.canSubmit || _controller.isLoading,
        );
    }
  }
}
