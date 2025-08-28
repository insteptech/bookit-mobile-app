import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
import 'package:bookit_mobile_app/app/theme/app_constants.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/back_icon.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/application/add_edit_class_schedule_controller.dart';
import '../widgets/class_details_tab.dart';
import '../widgets/class_schedule_tab.dart';

enum ClassTab { classDetails, classSchedule }

class AddEditClassAndScheduleScreen extends StatefulWidget {
  final Map<String, dynamic>? serviceData;
  final String? classId;
  final String? className;
  final bool isEditing;

  const AddEditClassAndScheduleScreen({
    super.key,
    this.serviceData,
    this.classId,
    this.className,
    this.isEditing = false,
  });

  @override
  State<AddEditClassAndScheduleScreen> createState() => _AddEditClassAndScheduleScreenState();
}

class _AddEditClassAndScheduleScreenState extends State<AddEditClassAndScheduleScreen> {
  late AddEditClassScheduleController _controller;
  ClassTab _selectedTab = ClassTab.classDetails;

  @override
  void initState() {
    super.initState();
    _controller = AddEditClassScheduleController();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize(
      serviceData: widget.serviceData,
      classId: widget.classId,
      isEditing: widget.isEditing,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<AddEditClassScheduleController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              backgroundColor: Colors.white,
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
                        onPressed: _initializeController,
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

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultHorizontalPadding,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppConstants.scaffoldTopSpacingWithBackButton),
                          
                          // Back button
                          BackIcon(
                            size: AppConstants.backButtonIconSize,
                            onPressed: () => Navigator.pop(context),
                          ),
                          
                          const SizedBox(height: AppConstants.backButtonToTitleSpacing),
                          
                          // Title
                          Text(
                            widget.isEditing ? 'Edit ${widget.className}' : 'Class details',
                            style: AppTypography.headingLg,
                          ),
                          
                          const SizedBox(height: AppConstants.headerToContentSpacing),
                          
                          // Tab switcher
                          _buildTabSelector(),
                          
                          const SizedBox(height: AppConstants.sectionSpacing),
                          
                          // Tab content
                          _buildTabContent(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultHorizontalPadding,
                      0,
                      AppConstants.defaultHorizontalPadding,
                      AppConstants.sectionSpacing,
                    ),
                    child: PrimaryButton(
                      text: _getButtonText(controller),
                      isDisabled: !_canProceed(controller) || controller.isSubmitting,
                      onPressed: () => _handleSave(controller),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      width: double.infinity, // Cover entire screen width
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Light gray background
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          // Class details tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = ClassTab.classDetails;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedTab == ClassTab.classDetails 
                    ? const Color(0xFFDBD4FF) // Active: light purple
                    : Colors.transparent,       // Inactive: transparent
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Class details',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: _selectedTab == ClassTab.classDetails 
                          ? FontWeight.w600  // Active: 550 (closest: 600)
                          : FontWeight.w400, // Inactive: 475 (closest: 400)
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Class schedule tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = ClassTab.classSchedule;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedTab == ClassTab.classSchedule 
                    ? const Color(0xFFDBD4FF) // Active: light purple
                    : Colors.transparent,       // Inactive: transparent
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Class schedule',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: _selectedTab == ClassTab.classSchedule 
                          ? FontWeight.w600  // Active: 550 (closest: 600)
                          : FontWeight.w400, // Inactive: 475 (closest: 400)
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case ClassTab.classDetails:
        return ClassDetailsTab();
      case ClassTab.classSchedule:
        return ClassScheduleTab();
    } 
  }

  bool _canProceed(AddEditClassScheduleController controller) {
    if (_selectedTab == ClassTab.classDetails) {
      return controller.canProceedToSchedule;
    } else {
      return controller.canSubmit;
    }
  }

  String _getButtonText(AddEditClassScheduleController controller) {
    if (controller.isSubmitting) {
      return widget.isEditing ? 'Updating...' : 'Creating...';
    }
    
    if (_selectedTab == ClassTab.classDetails) {
      return 'Class schedule';
    } else {
      // Check if no coaches are available for class scheduling
      if (controller.allStaffMembers.isEmpty) {
        return widget.isEditing ? 'Update class without schedule' : 'Add class without schedule';
      }
      return widget.isEditing ? 'Update' : 'Save';
    }
  }

  Future<void> _handleSave(AddEditClassScheduleController controller) async {
    if (_selectedTab == ClassTab.classDetails) {
      // Switch to schedule tab
      setState(() {
        _selectedTab = ClassTab.classSchedule;
      });
    } else {
      // Save the class and schedule
      final success = await controller.saveClassAndSchedule();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                ? 'Class updated successfully!' 
                : 'Class created successfully!'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (controller.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${controller.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}