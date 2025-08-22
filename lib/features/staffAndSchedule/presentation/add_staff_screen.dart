import 'package:bookit_mobile_app/app/localization/app_translations_delegate.dart';
import 'package:bookit_mobile_app/app/theme/app_colors.dart';
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
// import 'package:bookit_mobile_app/shared/components/atoms/secondary_button.dart';
import 'package:bookit_mobile_app/shared/components/atoms/back_icon.dart';
import 'package:flutter/material.dart';
import '../widgets/add_member_form.dart';

// Import the StaffTab enum
enum StaffTab { staffInfo, schedule }

enum StaffScreenButtonMode { continueToSchedule, saveOnly }

class AddStaffScreen extends StatefulWidget {
  final bool? isClass;
  final String? staffId;
  final String? staffName;
  final String? categoryId;
  final StaffScreenButtonMode buttonMode;

  const AddStaffScreen({
    super.key,
    this.isClass,
    this.staffId,
    this.staffName,
    this.categoryId,
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
  StaffTab _selectedTab = StaffTab.staffInfo;

  // State preservation for form fields
  String _formName = '';
  String _formEmail = '';
  String _formPhone = '';
  String? _formGender;
  
  // State preservation for schedule data
  List<bool> _scheduleSelectedDays = List.generate(7, (_) => false);
  Map<int, dynamic> _scheduleTimeRanges = {};
  List<dynamic> _scheduleSelectedLocations = List.filled(7, null, growable: false);


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
    // if (!_categoriesProvider.hasCategories) {
      await _categoriesProvider.fetchBusinessCategories();
    // }
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

  // void _handleSaveAndExit() async {
  //   // Only save if there's valid data to save
  //   if (_controller.canSubmit) {
  //     _isSaveAndExit = true;
  //     await _controller.submitStaffProfile();
  //     // Navigation will be handled by _handleSuccess callback
  //   } else {
  //     // If no valid data, just exit
  //     Navigator.pop(context);
  //   }
  // }

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
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(34, 2, 34, 2),
          child: _buildActionButtons(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16),
          child: _buildMainContent(context),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.scaffoldTopSpacingWithBackButton),
        
        _buildBackButton(),
        
        _buildTitle(context),
        
        const SizedBox(height: AppConstants.headerToContentSpacing),
        
        // Only show tab selector when isClass is not true
        if (widget.isClass != true) ...[
          _buildTabSelector(),
          const SizedBox(height: AppConstants.sectionSpacing),
        ],
        
        _buildTabContent(),
        
        const SizedBox(height: AppConstants.sectionSpacing),
      ],
    );
  }

  Widget _buildBackButton() {
    return BackIcon(size: 32, onPressed: () => Navigator.pop(context));
  }

  Widget _buildTitle(BuildContext context) {
    if(widget.staffId != null){
      return Text(
        widget.staffName ?? "",
        style: AppTypography.headingLg,
      );
    } else{
      return Text(
      widget.isClass == true 
        ? "Add coach" 
        : AppTranslationsDelegate.of(context).text("add_staff"),
      style: AppTypography.headingLg,
    );
  }
  }

  Widget _buildTabSelector() {
    return Container(
      width: 340,
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBoxColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = StaffTab.staffInfo;
                });
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: _selectedTab == StaffTab.staffInfo 
                    ? AppColors.secondary 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Staff info',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: _selectedTab == StaffTab.staffInfo 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = StaffTab.schedule;
                });
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: _selectedTab == StaffTab.schedule 
                    ? AppColors.secondary 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Staff schedule',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: _selectedTab == StaffTab.schedule 
                          ? FontWeight.w600 
                          : FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
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
    // When isClass is true, always show staff info content
    if (widget.isClass == true || _selectedTab == StaffTab.staffInfo) {
      return _buildStaffInfoContent();
    } else {
      return _buildScheduleContent();
    }
  }

  Widget _buildStaffInfoContent() {
    return AddMemberForm(
      isClass: widget.isClass,
      initialName: _formName,
      initialEmail: _formEmail,
      initialPhone: _formPhone,
      initialGender: _formGender,
      onDataChanged: (profile) {
        // Update preserved state
        _formName = profile.name;
        _formEmail = profile.email;
        _formPhone = profile.phoneNumber;
        _formGender = profile.gender;
        _controller.updateStaffProfile(profile);
      },
    );
  }


  Widget _buildScheduleContent() {
    return AddStaffScheduleTab(
      controller: _scheduleController,
      category: _categoriesProvider.categoriesForUI,
      onChange: () {
        setState(() {});
      },
      onDelete: () {},
      locations: _locations,
      initialSelectedDays: _scheduleSelectedDays,
      initialTimeRanges: _scheduleTimeRanges,
      initialSelectedLocations: _scheduleSelectedLocations,
      onScheduleChanged: (selectedDays, timeRanges, selectedLocations) {
        // Update preserved state
        _scheduleSelectedDays = List.from(selectedDays);
        _scheduleTimeRanges = Map.from(timeRanges);
        _scheduleSelectedLocations = List.from(selectedLocations);
      },
    );
  }


  Widget _buildActionButtons() {
    try {
      // Safely check schedule state with null safety
      final scheduleIsAvailable = _scheduleController.schedule.isAvailable;
      
      // Safely check controller states
      final controllerCanSubmit = _controller.canSubmit;
      final scheduleControllerIsValid = _scheduleController.isValid();
      final isLoading = _controller.isLoading;
      
      // Updated logic: 
      // - If staff availability is OFF, only require staff form completion
      // - If staff availability is ON, require both staff form AND complete schedule (services + day schedules)
      // - Always require basic staff controller validation (form fields filled)
      final bool isDisabled = _selectedTab == StaffTab.schedule 
          ? (!controllerCanSubmit || (scheduleIsAvailable && !scheduleControllerIsValid))
          : !controllerCanSubmit;
      
      // Show warning only when on schedule tab, availability is ON, but schedule is incomplete
      final needsScheduleCompletion = _selectedTab == StaffTab.schedule && 
          scheduleIsAvailable && 
          !scheduleControllerIsValid;
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning message for schedule tab - only when availability is ON but schedule is incomplete
          if (needsScheduleCompletion) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "Complete schedule details to save (select services and set working hours)",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          // Main action buttons
          if (widget.isClass == true || _selectedTab == StaffTab.staffInfo) ...[
            // Staff info tab buttons
            PrimaryButton(
              text: isLoading
                  ? AppTranslationsDelegate.of(context).text("adding_staff")
                  : widget.isClass == true 
                    ? "Continue to schedule"
                    : "Staff schedule",
              onPressed: isLoading
                  ? null
                  : controllerCanSubmit
                      ? () {
                          if (widget.isClass == true) {
                            // For classes, save staff and navigate to class schedule
                            _addStaffWithScheduleController.submit();
                          } else {
                            // For regular staff, switch to schedule tab
                            setState(() {
                              _selectedTab = StaffTab.schedule;
                            });
                          }
                        }
                      : null,
              isDisabled: !controllerCanSubmit,
            ),
            // const SizedBox(height: AppConstants.smallContentSpacing + 2),
            // SecondaryButton(
            //   text: "Save & exit",
            //   onPressed: _handleSaveAndExit,
            // ),
          ] else ...[
            // Schedule tab button
            PrimaryButton(
              text: isLoading
                  ? AppTranslationsDelegate.of(context).text("adding_staff")
                  : "Save",
              onPressed: isLoading ? null : isDisabled ? null : () {
                if (!scheduleIsAvailable) {
                  // If availability is OFF, save only staff info
                  _addStaffWithScheduleController.submit();
                } else {
                  // If availability is ON, save staff with schedule
                  _addStaffWithScheduleController.submit();
                }
              },
              isDisabled: isDisabled,
            ),
          ],
        ],
      );
    } catch (e) {
      // Fallback UI if there's an error in button rendering
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            text: "Save",
            onPressed: () => Navigator.pop(context),
            isDisabled: false,
          ),
        ],
      );
    }
  }
}
