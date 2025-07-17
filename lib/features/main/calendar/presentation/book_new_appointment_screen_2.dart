import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 

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
  bool _isLoading = true;
  String _appointmentSummary = "Loading details...";

  // For Autocomplete Client Search
  final TextEditingController _clientController = TextEditingController();
  final FocusNode _clientFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  @override
  void dispose() {
    _clientController.dispose();
    _clientFocusNode.dispose();
    super.dispose();
  }

  // --- Data and UI Initialization ---
  Future<void> _initializeData() async {
    // 1. Build the summary string from the payload
    _buildAppointmentSummary();
    setState(() {
      _isLoading = false;
    });
  }

  void _buildAppointmentSummary() {
    try {
      final payload = widget.partialPayload;
      final duration = payload['duration_minutes'];
      final serviceName = payload['service_name'];
      final practitionerName = payload['practitioner_name'];
      
      // Parse the UTC date string back to a DateTime object
      final startTime = DateTime.parse(payload['date']).toLocal();

      // Format time (e.g., "1:00 PM") and date (e.g., "Sunday, May 11, 2025")
      final formattedTime = DateFormat('h:mm a').format(startTime);
      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(startTime);

      setState(() {
        _appointmentSummary =
            "$duration min - $serviceName at [$formattedTime] on [$formattedDate] with $practitionerName";
      });
    } catch (e) {
      setState(() {
        _appointmentSummary = "Could not load appointment details.";
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLocation = ref.watch(locationsProvider)
      .firstWhere((loc) => loc['id'] == widget.partialPayload['location_id'], orElse: () => {'title': '...'});

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
                children: [
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    "Book a new appointment",
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 16),
                  // Location selector (Read-only
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [GestureDetector(
                            onTap: () async {
                            },
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
                  // This text now dynamically displays the summary
                  Text(
                    _appointmentSummary,
                    style: AppTypography.headingSm,
                  ),
                  const SizedBox(height: 24),
                  Text("Client", style: AppTypography.headingSm),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        controller: _clientController,
                        hintText: "Search for client by name",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Primary action button at the bottom
            Padding(padding: EdgeInsets.symmetric(horizontal: 34, vertical: 20), child: PrimaryButton(onPressed: (){}, isDisabled: true, text: "Confirm booking")
            ,)
            
          ],
        ),
      ),
    );
  }
}

// --- Mocked Function for demonstration ---
Future<List<Map<String, dynamic>>> _fetchClients() async {
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
  return [
    {'id': 'client-uuid-1', 'full_name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'id': 'client-uuid-2', 'full_name': 'Bob Williams', 'email': 'bob@example.com'},
    {'id': 'client-uuid-3', 'full_name': 'Charlie Brown', 'email': 'charlie@example.com'},
    {'id': 'client-uuid-4', 'full_name': 'Diana Prince', 'email': 'diana@example.com'},
    {'id': 'client-uuid-5', 'full_name': 'Alicia Keys', 'email': 'alicia@example.com'},
  ];
}