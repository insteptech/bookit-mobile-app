import 'package:bookit_mobile_app/features/calendar/widgets/upcoming_appointments.dart';
import 'package:bookit_mobile_app/shared/components/organisms/sticky_header_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';

class ViewAllAppointmentsScreen extends ConsumerStatefulWidget {
  const ViewAllAppointmentsScreen({super.key});

  @override
  ConsumerState<ViewAllAppointmentsScreen> createState() => _ViewAllAppointmentsScreenState();
}

class _ViewAllAppointmentsScreenState extends ConsumerState<ViewAllAppointmentsScreen> {
  List<Map<String, dynamic>> staffAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final locationId = ref.read(activeLocationProvider);
    setState(() {
      isLoading = true;
    });
    final data = await APIRepository.getAppointments(locationId);
    setState(() {
      staffAppointments = List<Map<String, dynamic>>.from(data['data']);
      isLoading =false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeaderScaffold(
      title: "Appointments",
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      content: AppointmentsWidget(
        staffAppointments: staffAppointments,
        isLoading: isLoading,
        showBottomOptions: false,
      ),
      buttonText: "Book a new appointment",
      onButtonPressed: () {
        context.push("/book_new_appointment");
      },
      isButtonDisabled: false,
    );
  }
}