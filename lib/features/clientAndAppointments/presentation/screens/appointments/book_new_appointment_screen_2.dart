import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/provider.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/widgets/appointment_summary_widget.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/widgets/client_search_widget.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/widgets/clients_appointments_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookNewAppointmentScreen2 extends ConsumerStatefulWidget {
  final Map<String, dynamic> partialPayload;
  const BookNewAppointmentScreen2({super.key, required this.partialPayload});

  @override
  ConsumerState<BookNewAppointmentScreen2> createState() =>
      _BookNewAppointmentScreen2State();
}

class _BookNewAppointmentScreen2State
    extends ConsumerState<BookNewAppointmentScreen2> {
  // --- State Variables ---
  bool _isLoading = false;

  // For Client Search
  final TextEditingController _clientController = TextEditingController();
  final FocusNode _clientFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  Map<String, dynamic>? _selectedClient;

  @override
  void dispose() {
    _clientController.dispose();
    _clientFocusNode.dispose();
    super.dispose();
  }

  void _selectClient(Map<String, dynamic> client) {
    setState(() {
      _selectedClient = client;
      _clientController.text = client['full_name'] ?? '';
    });
    _clientFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLocation = ref.watch(locationsProvider).firstWhere(
        (loc) => loc['id'] == widget.partialPayload['location_id'],
        orElse: () => {'title': '...'});
    

    return ClientsAppointmentsScaffold(
      title: "Book a new appointment",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {},
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.onSurface),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(activeLocation["title"]),
                ),
              )
            ],
          ),
          const SizedBox(height: 48),
          AppointmentSummaryWidget(partialPayload: widget.partialPayload),
          const SizedBox(height: 24),
          const Text("Client", style: AppTypography.headingSm),
          const SizedBox(height: 8),

          ClientSearchWidget(
            layerLink: _layerLink,
            controller: _clientController,
            focusNode: _clientFocusNode,
            onClientSelected: _selectClient,
          ),

          const SizedBox(height: 8),
        
          GestureDetector(
            onTap: () async {
              final result = await context.push(
                "/add_new_client",
                extra: widget.partialPayload,
              );
              
              // If a client was created, select it
              if (result != null && result is Map<String, dynamic>) {
                _selectClient(result);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.add_circle_outline_outlined, color: theme.colorScheme.primary, size: 18,),
                const SizedBox(width: 5),
                Text(
                  "Add new client",
                  style: AppTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      buttonText: _isLoading ? "Booking..." : "Confirm booking",
      onButtonPressed: _selectedClient != null
          ? () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await ref.read(appointmentControllerProvider.notifier).bookAppointment(
                  businessId: widget.partialPayload['business_id'],
                  locationId: widget.partialPayload['location_id'],
                  businessServiceId: widget.partialPayload['business_service_id'],
                  practitionerId: widget.partialPayload['practitioner'],
                  date: DateTime.parse(widget.partialPayload['date']),
                  startTime: widget.partialPayload['start_from'],
                  endTime: widget.partialPayload['end_at'],
                  userId: widget.partialPayload['user_id'],
                  durationMinutes: widget.partialPayload['duration_minutes'],
                  serviceName: widget.partialPayload['service_name'],
                  practitionerName: widget.partialPayload['practitioner_name'],
                  clientId: _selectedClient!['id'].toString(),
                );
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment booked successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Navigate to home screen with a refresh parameter
                  context.go("/home_screen?refresh=true");
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to book appointment: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            }
          : null,
      isButtonDisabled: (_selectedClient == null || _isLoading),
    );
  }
}
