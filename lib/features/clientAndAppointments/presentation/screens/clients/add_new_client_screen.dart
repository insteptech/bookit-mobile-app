import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/provider.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/widgets/appointment_summary_widget.dart';
import 'package:bookit_mobile_app/features/clientAndAppointments/presentation/utils/validation_service.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewClientScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> partialPayload;

  const AddNewClientScreen({super.key, required this.partialPayload});

  @override
  ConsumerState<AddNewClientScreen> createState() => _AddNewClientScreenState();
}

class _AddNewClientScreenState extends ConsumerState<AddNewClientScreen> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _getFormErrors() {
    return ValidationService.validateClientForm(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );
  }

  Future<void> _saveAndConfirm() async {
    // Check for validation errors first
    final error = _getFormErrors();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // TODO: Implement client creation when backend route is available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client creation API not yet implemented on backend'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // For now, just pop back without creating a client
      Navigator.pop(context);
      
      // When the API is implemented, uncomment the following:
      /*
      final clientController = ref.read(clientControllerProvider.notifier);
      final newClient = await clientController.createClient(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newClient);
      }
      */
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create client: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLocation = ref.watch(locationsProvider).firstWhere(
        (loc) => loc['id'] == widget.partialPayload['location_id'],
        orElse: () => {'title': '...'});
    
    final clientState = ref.watch(clientControllerProvider);

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
                    "Add new client",
                    style: AppTypography.headingLg,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.onSurface),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(activeLocation["title"] ?? "Unknown Location"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  AppointmentSummaryWidget(partialPayload: widget.partialPayload),
                  const SizedBox(height: 40),
                  
                  // Client Information Form
                  const Text("Client Information", style: AppTypography.headingSm),
                  const SizedBox(height: 24),
                  
                  const Text("Full Name", style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  InputField(
                    controller: _nameController,
                    hintText: "Enter client's full name",
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text("Email", style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  InputField(
                    controller: _emailController,
                    hintText: "Enter client's email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text("Phone Number", style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  InputField(
                    controller: _phoneController,
                    hintText: "Enter client's phone number",
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
              child: PrimaryButton(
                onPressed: clientState.isLoading ? null : _saveAndConfirm,
                isDisabled: clientState.isLoading,
                text: clientState.isLoading ? "Creating..." : "Create Client",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
