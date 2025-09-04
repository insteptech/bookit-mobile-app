import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/controllers/staff_controller.dart';
import 'package:bookit_mobile_app/core/controllers/appointments_controller.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/appointment_section_widget.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/class_schedule_section_widget.dart';

class DashboardContentWidget extends ConsumerWidget {
  const DashboardContentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessControllerProvider);
    final staffState = ref.watch(staffControllerProvider);
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    
    final businessType = businessState.businessType;
    
    // Intelligent loading state logic
    final isInitialLoading = _shouldShowLoading(businessState, staffState, appointmentsState);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isInitialLoading 
        ? const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          )
        : Column(
            key: ValueKey('dashboard_content_loaded'),
            children: _buildSectionsForBusinessTypeAndStaff(businessType, staffState),
          ),
    );
  }

  bool _shouldShowLoading(businessState, staffState, appointmentsState) {
    // Show loading only if:
    // 1. Business type is still loading AND no cached data
    // 2. Staff is still loading AND no cached data  
    // 3. If staff exists but appointments/classes are loading for the first time
    
    if (businessState.isLoading && businessState.businessCategories.isEmpty) {
      return true; // Business data not loaded yet
    }
    
    if (staffState.isLoading && staffState.allStaff.isEmpty) {
      return true; // Staff data not loaded yet
    }
    
    // If business type and staff are loaded, only show loading if:
    // - Business is appointment-only, has appointment staff, but appointments are loading for first time
    // - Business is class-only, has class staff, but classes are loading for first time
    // - Business is both and relevant data is loading for first time
    
    final businessType = businessState.businessType;
    
    if (businessType == BusinessType.appointmentOnly && 
        staffState.hasAppointmentStaff && 
        appointmentsState.isLoading && 
        appointmentsState.allStaffAppointments.isEmpty) {
      return true;
    }
    
    if (businessType == BusinessType.classOnly && 
        staffState.hasClassStaff) {
      // Would need class loading state here, but for now assume loading when staff exists
      // This is a simplified version
      return false;
    }
    
    if (businessType == BusinessType.both) {
      // For both type, show loading only if relevant staff exists but data is loading for first time
      if (staffState.hasAppointmentStaff && 
          appointmentsState.isLoading && 
          appointmentsState.allStaffAppointments.isEmpty) {
        return true;
      }
    }
    
    return false;
  }

  List<Widget> _buildSectionsForBusinessTypeAndStaff(BusinessType businessType, staffState) {
    List<Widget> widgets = [];
    
    // Show appointments section if it's appointment-only or both
    if (businessType == BusinessType.appointmentOnly || businessType == BusinessType.both) {
      widgets.add(
        AppointmentSectionWidget(businessType: businessType),
      );
    }
    
    // Show class schedule section if it's class-only or both
    if (businessType == BusinessType.classOnly || businessType == BusinessType.both) {
      widgets.add(
        const ClassScheduleSectionWidget(),
      );
    }
    
    return widgets;
  }
}
