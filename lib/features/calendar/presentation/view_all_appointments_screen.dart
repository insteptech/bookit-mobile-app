import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/calendar/widgets/upcoming_appointments.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
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
              const Text("Appointments", style: AppTypography.headingLg),
              const SizedBox(height: 48),
              AppointmentsWidget(
                staffAppointments: staffAppointments,
                isLoading: isLoading,
                showBottomOptions: false,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(34, 20, 34, 20),
        child: PrimaryButton(
          text: "Book a new appointment",
          onPressed: () {
            context.push("/book_new_appointment");
          },
          isDisabled: false,
        ),
      ),
    );
  }
}