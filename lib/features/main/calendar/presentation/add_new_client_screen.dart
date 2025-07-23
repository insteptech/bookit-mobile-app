import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/core/providers/location_provider.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  
  // State variables
  bool _isLoading = false;
  String _appointmentSummary = "Loading details...";

  @override
  void initState() {
    super.initState();
    _buildAppointmentSummary();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _buildAppointmentSummary() {
    try {
      final payload = widget.partialPayload;
      final duration = payload['duration_minutes'];
      final serviceName = payload['service_name'];
      final startTime = DateTime.parse(payload['date']).toLocal();
      final formattedTime = DateFormat('h:mm a').format(startTime);
      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(startTime);

      setState(() {
        _appointmentSummary =
            "$duration min - $serviceName at [$formattedTime] on [$formattedDate]";
      });
    } catch (e) {
      setState(() {
        _appointmentSummary = "Could not load appointment details";
      });
    }
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // Phone validation (basic format check)
  bool _isValidPhone(String phone) {
    // Remove all non-digit characters for validation
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  String? _getFormErrors() {
    if (_nameController.text.trim().isEmpty) {
      return "Name is required";
    }
    if (_nameController.text.trim().length < 2) {
      return "Name must be at least 2 characters";
    }
    if (_emailController.text.trim().isEmpty) {
      return "Email is required";
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      return "Please enter a valid email address";
    }
    if (_phoneController.text.trim().isEmpty) {
      return "Phone number is required";
    }
    if (!_isValidPhone(_phoneController.text.trim())) {
      return "Please enter a valid phone number (10-15 digits)";
    }
    return null;
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Create client payload
      final clientPayload = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
      };

      // Create the client account
      final response = await APIRepository.createClientAccount(payload: clientPayload);
      
      if (response.statusCode == 201) {
        // Success case - extract profile data
        final responseData = response.data;
        final profileData = responseData['data']['profile'];
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Client "${profileData['full_name']}" created successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate back with the client data in the expected format
          Navigator.pop(context, {
            'id': profileData['id'],
            'full_name': profileData['full_name'],
            'email': profileData['email'],
            'phone_number': profileData['phone'],
          });
        }
      } else if (response.statusCode == 409) {
        // Handle email conflict error
        final responseData = response.data;
        final errorMessage = responseData['message'] ?? 'Email already exists';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        // Handle other error status codes
        final responseData = response.data;
        final errorMessage = responseData['message'] ?? 'Failed to create client account';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Handle network errors or other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: Unable to create client account'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeLocation = ref.watch(locationsProvider).firstWhere(
        (loc) => loc['id'] == widget.partialPayload['location_id'],
        orElse: () => {'title': '...'});

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
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
                    "Book new appointment",
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
                        child: Text(activeLocation["title"]),
                      )
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    _appointmentSummary,
                    style: AppTypography.headingSm,
                  ),
                  const SizedBox(height: 24),
                  const Text("Client information", style: AppTypography.headingSm),
                  const SizedBox(height: 16),
                  
                  // Name Field
                  const Text("First and last name", style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  InputField(
                    hintText: "First and last name",
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  const Text("Email", style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  InputField(
                    hintText: "email@theiremail.com",
                    controller: _emailController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mobile Phone Field
                  const Text("Mobile phone", style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  InputField(
                    hintText: "Mobile phone",
                    controller: _phoneController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  
                  // Help text for phone format
                  Text(
                    "Enter 10-15 digits (e.g., +1234567890 or 1234567890)",
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
              child: PrimaryButton(
                onPressed: !_isLoading ? _saveAndConfirm : null,
                isDisabled: _isLoading,
                text: _isLoading ? "Creating client..." : "Save and confirm",
              ),
            ),
          ],
        ),
      ),
    );
  }
}