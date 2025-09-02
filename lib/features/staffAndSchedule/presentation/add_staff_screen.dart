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
import 'package:bookit_mobile_app/features/staffAndSchedule/models/staff_profile_request_model.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/widgets/add_staff_schedule_tab.dart';
import 'package:bookit_mobile_app/features/staffAndSchedule/presentation/class_selection_screen.dart';
import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
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

  // Override buttonMode getter to always return continueToSchedule for classes
  StaffScreenButtonMode get effectiveButtonMode {
    if (isClass == true) {
      return StaffScreenButtonMode.continueToSchedule;
    }
    return buttonMode;
  }

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
  List<String> _formCategoryIds = [];
  bool _isDataLoaded = false;
  
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
    _addStaffWithScheduleController.setCallbacks(
      onStateChanged: () => setState(() {}),
      onSuccess: _handleSuccess,
      onError: _handleError,
    );
    _setupAutoSelection();
    
    // Prefill data if staffId is provided
    if (widget.staffId != null) {
      // Use a post-frame callback to ensure widgets are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillStaffData();
      });
    }
  }

  void _fetchBusinessCategories() async {
    // if (!_categoriesProvider.hasCategories) {
      await _categoriesProvider.fetchBusinessCategories();
    // }
  }

  Future<void> _prefillStaffData() async {
    try {
      final response = await APIRepository.getStaffDetailsAndScheduleById(widget.staffId!);
      
      if (response.statusCode == 200 && response.data['status'] == true) {
        final staffList = response.data['data']['staff'] as List<dynamic>?;
        if (staffList == null || staffList.isEmpty) {
          _handleError('No staff data found');
          return;
        }
        final staffData = staffList[0];
        
        // Map staff info from API response to form state
        setState(() {
          _formName = staffData['name'] ?? '';
          _formEmail = staffData['email'] ?? '';
          _formPhone = staffData['phone_number'] ?? '';
          _formGender = staffData['gender'];
        });

        // Create StaffProfile from API data and update controller
        final List<String> categoryIds = [];
        try {
          if (staffData['categories'] != null && staffData['categories'] is List) {
            final categories = staffData['categories'] as List<dynamic>;
            for (final cat in categories) {
              if (cat != null && cat is Map && cat['id'] != null) {
                categoryIds.add(cat['id'].toString());
              }
            }
          }
        } catch (e) {
          // Handle category parsing errors gracefully
          debugPrint('Error parsing categories: $e');
        }
        
        // Store category IDs for later use
        _formCategoryIds = categoryIds;

        final staffProfile = StaffProfile(
          id: widget.staffId, // Use the widget.staffId for editing
          name: _formName,
          email: _formEmail,
          phoneNumber: _formPhone,
          gender: _formGender ?? '',
          categoryIds: categoryIds.isNotEmpty ? categoryIds : (widget.categoryId != null ? [widget.categoryId!] : []),
          profilePhotoUrl: staffData['profile_photo_url'],
          forClass: widget.isClass == true,
        );

        _controller.updateStaffProfile(staffProfile);
        
        // Map schedule data if available
        _prefillScheduleData(staffData['schedules'] ?? [], staffData['services'] ?? []);
        
        // Mark data as loaded and trigger rebuild
        setState(() {
          _isDataLoaded = true;
        });

      } else {
        _handleError('Failed to load staff data');
      }
    } catch (e) {
      _handleError('Error loading staff data: ${e.toString()}');
    }
  }

  void _prefillScheduleData(List<dynamic> schedules, List<dynamic> services) {
    if (schedules.isEmpty) return;

    // Map schedule data to form state 
    Map<String, int> dayIndexMap = {
      'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3,
      'friday': 4, 'saturday': 5, 'sunday': 6
    };

    // Reset schedule state
    _scheduleSelectedDays = List.generate(7, (_) => false);
    _scheduleTimeRanges = {};
    _scheduleSelectedLocations = List.filled(7, null, growable: false);

    // Process each schedule entry
    for (var schedule in schedules) {
      final dayName = schedule['day']?.toLowerCase();
      final dayIndex = dayIndexMap[dayName];
      
      if (dayIndex != null) {
        _scheduleSelectedDays[dayIndex] = true;
        _scheduleTimeRanges[dayIndex] = {
          'from': schedule['from'],
          'to': schedule['to'],
        };
        
        // Find and set location
        final locationId = schedule['location_id']?.toString();
        if (locationId != null) {
          final location = _locations.firstWhere(
            (loc) => loc['id'] == locationId,
            orElse: () => {'id': locationId, 'name': schedule['location']['title'] ?? 'Unknown Location'},
          );
          _scheduleSelectedLocations[dayIndex] = location;
        }
      }
    }

    // Extract service IDs from the API response
    List<String> serviceIds = services
        .map((service) => service['service_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    // Update schedule controller with prefilled data
    _scheduleController.prefillScheduleData(
      selectedDays: _scheduleSelectedDays,
      timeRanges: _scheduleTimeRanges,
      selectedLocations: _scheduleSelectedLocations,
      services: serviceIds,
    );
  }

  void _setupAutoSelection() {
    // Auto-selection is no longer needed since services are now fetched dynamically from API
    // based on the selected categories. Users can manually select which services they want to offer.
  }

  @override
  void dispose() {
    // Clear callbacks to prevent calls after disposal
    _controller.setCallbacks(
      onStateChanged: () {},
      onSuccess: (_) {},
      onError: (_) {},
    );
    _addStaffWithScheduleController.setCallbacks(
      onStateChanged: () {},
      onSuccess: (_) {},
      onError: (_) {},
    );
    _controller.dispose();
    super.dispose();
  }


  void _handleSuccess(String message) {
    if (!mounted) return;
    
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Widget is disposed, ignore the snackbar
      debugPrint('ScaffoldMessenger call failed: widget disposed');
    }
    
    
    // Handle navigation based on which action was triggered
    if (_isSaveAndExit) {
      // For save and exit, just go back to previous screen
      Navigator.pop(context);
    } else {
      // For continue to schedule, handle navigation based on button mode
      if (widget.effectiveButtonMode == StaffScreenButtonMode.continueToSchedule) {
        // Navigate based on whether this is for a class or regular staff
        if (widget.isClass == true) {
          // Navigate to class selection screen with the category ID
          // Get category ID from widget or from the staff profile's first category
          String? categoryIdToUse = widget.categoryId;
          if (categoryIdToUse == null && _controller.staffProfile?.categoryIds.isNotEmpty == true) {
            categoryIdToUse = _controller.staffProfile!.categoryIds.first;
          }
          
          // if (categoryIdToUse != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassSelectionScreen(categoryId: categoryIdToUse!),
              ),
            );
          // } else {
          //   NavigationService.push("/add_class_schedule");
          // }
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
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppTranslationsDelegate.of(context).text("error")}: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Widget is disposed, ignore the snackbar
      debugPrint('ScaffoldMessenger call failed: widget disposed');
    }
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
    String title;
    if(widget.staffId != null){
      title = widget.staffName ?? "";
    } else {
      title = widget.isClass == true 
        ? "Add coach" 
        : AppTranslationsDelegate.of(context).text("add_staff");
    }

    // Get button configuration
    final buttonConfig = _getButtonConfiguration();

    return StickyHeaderScaffold(
      title: title,
      physics: const ClampingScrollPhysics(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show tab selector when isClass is not true
          if (widget.isClass != true) ...[
            _buildTabSelector(),
            const SizedBox(height: AppConstants.sectionSpacing),
          ],
          
          _buildTabContent(),
          
          // Warning message for schedule tab if needed
          if (_shouldShowScheduleWarning()) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
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
          
          // Add bottom padding to prevent content from being hidden behind fixed button
          const SizedBox(height: 80),
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          padding: EdgeInsets.only(
            left: AppConstants.defaultScaffoldPadding.horizontal / 2,
            right: AppConstants.defaultScaffoldPadding.horizontal / 2,
            top: 16,
            bottom: 20,
          ),
          child: PrimaryButton(
            text: buttonConfig['text'] ?? "Save",
            onPressed: buttonConfig['onPressed'],
            isDisabled: buttonConfig['isDisabled'] ?? false,
          ),
        ),
      ),
    );
  }

  bool _shouldShowScheduleWarning() {
    try {
      final scheduleIsAvailable = _scheduleController.schedule.isAvailable;
      final controllerCanSubmit = _controller.canSubmit;
      final scheduleControllerIsValid = _scheduleController.isValid();
      
      return _selectedTab == StaffTab.schedule && 
             scheduleIsAvailable && 
             !scheduleControllerIsValid &&
             controllerCanSubmit;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _getButtonConfiguration() {
    try {
      // Safely check schedule state with null safety
      final scheduleIsAvailable = _scheduleController.schedule.isAvailable;
      
      // Safely check controller states
      final controllerCanSubmit = _controller.canSubmit;
      final scheduleControllerIsValid = _scheduleController.isValid();
      final isLoading = _controller.isLoading;
      final isScheduleLoading = _addStaffWithScheduleController.isLoading;
      
      if (widget.isClass == true || _selectedTab == StaffTab.staffInfo) {
        // Staff info tab button
        return {
          'text': isLoading
              ? AppTranslationsDelegate.of(context).text("adding_staff")
              : widget.isClass == true 
                ? "Continue to schedule"
                : "Staff schedule",
          'onPressed': isLoading
              ? null
              : controllerCanSubmit
                  ? () {
                      if (widget.isClass == true) {
                        // For classes, save staff profile only (no schedule required)
                        _isSaveAndExit = false;
                        _controller.submitStaffProfile();
                      } else {
                        // For regular staff, switch to schedule tab
                        setState(() {
                          _selectedTab = StaffTab.schedule;
                        });
                      }
                    }
                  : null,
          'isDisabled': !controllerCanSubmit,
        };
      } else {
        // Schedule tab button
        final bool isDisabled = !controllerCanSubmit || (scheduleIsAvailable && !scheduleControllerIsValid);
        
        return {
          'text': isScheduleLoading ? "Saving..." : "Save",
          'onPressed': isScheduleLoading ? null : isDisabled ? null : () {
            _isSaveAndExit = true; // Set flag to navigate back after save
            _addStaffWithScheduleController.submit();
          },
          'isDisabled': isDisabled || isScheduleLoading,
        };
      }
    } catch (e) {
      // Fallback configuration
      return {
        'text': "Save",
        'onPressed': () => Navigator.pop(context),
        'isDisabled': false,
      };
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
      key: ValueKey('staff_form_${_isDataLoaded ? _formName : 'empty'}'), // Force rebuild when data loads
      isClass: widget.isClass,
      initialName: _formName,
      initialEmail: _formEmail,
      initialPhone: _formPhone,
      initialGender: _formGender,
      initialCategoryIds: _isDataLoaded ? _formCategoryIds : null,
      initialId: widget.staffId, // Pass the staff ID for editing
      onDataChanged: (profile) {
        // Update preserved state
        _formName = profile.name;
        _formEmail = profile.email;
        _formPhone = profile.phoneNumber;
        _formGender = profile.gender;
        
        // Ensure we preserve category IDs from prefilled data and staff ID
        final updatedProfile = StaffProfile(
          id: profile.id ?? widget.staffId, // Ensure staff ID is preserved
          name: profile.name,
          email: profile.email,
          phoneNumber: profile.phoneNumber,
          gender: profile.gender,
          categoryIds: profile.categoryIds.isEmpty && _formCategoryIds.isNotEmpty 
              ? _formCategoryIds 
              : profile.categoryIds,
          profileImage: profile.profileImage,
          profilePhotoUrl: profile.profilePhotoUrl,
          forClass: widget.isClass == true,
        );
        
        _controller.updateStaffProfile(updatedProfile);
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


}
