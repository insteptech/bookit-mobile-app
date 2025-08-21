import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/services/navigation_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/core/providers/business_categories_provider.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_staff_with_schedule_controller.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/add_staff_schedule_tab.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/back_icon.dart';
import 'package:flutter/material.dart';
import '../widgets/add_member_form.dart';

enum StaffScreenButtonMode { continueToSchedule, saveOnly }

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
  final StaffScheduleController _scheduleController = StaffScheduleController();
  late final AddStaffWithScheduleController _addStaffWithScheduleController;
  List<Map<String, dynamic>> _locations = [];
  final BusinessCategoriesProvider _categoriesProvider = BusinessCategoriesProvider.instance;


  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchBusinessCategories();
    _controller = AddStaffController();
    _addStaffWithScheduleController = AddStaffWithScheduleController(
      staffController: _controller,
      scheduleController: _scheduleController,
    );
    _controller.setCallbacks(
      onStateChanged: () => setState(() {}),
      onSuccess: _handleSuccess,
      onError: _handleError,
    );
    _setupAutoSelection();
  }

  void _fetchBusinessCategories() async {
    if (!_categoriesProvider.hasCategories) {
      await _categoriesProvider.fetchBusinessCategories();
    }
    print("fetching business service categories");
    final data = await APIRepository.getBusinessServiceCategories();
    print(data);
  }

  void _setupAutoSelection() {
    // Auto-select categories based on is_class property
    if (widget.isClass != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetCategories = _categoriesProvider.getCategoriesByType(isClass: widget.isClass!);
        for (final category in targetCategories) {
          _scheduleController.toggleService(category['id']);
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _handleSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      await _controller.submitStaffProfile();
      // Navigation will be handled by _handleSuccess callback
    } else {
      // If no valid data, just exit
      Navigator.pop(context);
    }
  }

  void _handleError(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppTranslationsDelegate.of(context).text("error")}: $error',
        ),
      ),
    );
  }

  void _fetchLocations() async {
    try {
      final locations = await APIRepository.getBusinessLocations();
      setState(() {
        _locations = List<Map<String, dynamic>>.from(locations['rows'].map((loc) => {
          'id': loc['id'].toString(),
          'name': loc['title'].toString(),
        }));
      });
    } catch (error) {
      _handleError(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top:
            false, // Avoid duplicating top padding since body already uses SafeArea
        child: Padding(
          padding: const EdgeInsets.fromLTRB(34, 2, 34, 2),
          child: _buildActionButtons(),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: AppConstants.scaffoldTopSpacingWithBackButton,
              ),
              BackIcon(size: 32, onPressed: () => Navigator.pop(context)),
              Text(
                AppTranslationsDelegate.of(context).text("add_staff"),
                style: AppTypography.headingLg,
              ),
              const SizedBox(height: 48),
              // Render add staff form
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: AddMemberForm(
                  isClass: widget.isClass,
                  onDataChanged:
                      (profile) => _controller.updateStaffProfile(profile),
                ),
              ),

              AddStaffScheduleTab(
                controller: _scheduleController,
                category: _categoriesProvider.categoriesForUI,
                onChange: () {},
                onDelete: () {},
                locations: _locations,
              ),

              // Action buttons
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return PrimaryButton(
      text:
          _controller.isLoading
              ? AppTranslationsDelegate.of(context).text("adding_staff")
              : "Save",
      onPressed: _controller.isLoading ? null : _addStaffWithScheduleController.submit,
      isDisabled: !_addStaffWithScheduleController.canSubmit,
    );
  }
}
