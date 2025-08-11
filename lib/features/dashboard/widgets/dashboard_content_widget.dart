import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookit_mobile_app/core/controllers/business_controller.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/features/dashboard/models/business_category_model.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/appointment_section_widget.dart';
import 'package:bookit_mobile_app/features/dashboard/widgets/class_schedule_section_widget.dart';

class DashboardContentWidget extends ConsumerWidget {
  const DashboardContentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessControllerProvider);
    final activeLocation = ref.watch(activeLocationProvider); // Watch location changes
    final isLoading = businessState.isLoading;
    final businessType = businessState.businessType;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading 
        ? const Center(
            key: ValueKey('loading'),
            child: CircularProgressIndicator(),
          )
        : Container(
            key: ValueKey('dashboard_content_$activeLocation'), // Include location in key
            child: Column(
              children: _buildSectionsForBusinessType(businessType),
            ),
          ),
    );
  }

  List<Widget> _buildSectionsForBusinessType(BusinessType businessType) {
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
