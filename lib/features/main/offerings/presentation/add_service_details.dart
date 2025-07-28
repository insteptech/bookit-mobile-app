import 'package:bookit_mobile_app/core/services/remote_services/network/api_provider.dart';
import 'package:bookit_mobile_app/features/main/offerings/widgets/add_service_details_form.dart';
import 'package:bookit_mobile_app/features/main/offerings/widgets/offerings_add_service_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/shared/components/atoms/primary_button.dart';

class AddServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? servicePayload;
  const AddServiceDetailsScreen({super.key, required this.servicePayload});

  @override
  State<AddServiceDetailsScreen> createState() => _AddServiceDetailsScreenState();
}

class _AddServiceDetailsScreenState extends State<AddServiceDetailsScreen> {
  final Map<String, GlobalKey<EnhancedServicesFormState>> formKeys = {};
  bool isButtonDisabled = false;
  List<Map<String, dynamic>> services = [];
  String categoryName = '';
  List<Map<String, dynamic>> allStaff = [];
  List<Map<String, dynamic>> allLocations = [];

  @override
  void initState() {
    super.initState();
    final servicesData = widget.servicePayload?['services'] as List<dynamic>?;
    _fetchAllStaff();
    _fetchLocations();
    if (servicesData != null) {
      services = servicesData.cast<Map<String, dynamic>>();
    }
    categoryName = widget.servicePayload?['categoryName'] as String? ?? '';
    print('Services: $services');
    print('Category Name: $categoryName');
  }

  Future<void> _fetchAllStaff() async {
    try {
      final response = await APIRepository.getAllStaffList();
      final staffData = response.data['data']['rows'] as List<dynamic>?;
      if (staffData != null) {
        setState(() {
          allStaff = staffData.cast<Map<String, dynamic>>();
        });
        debugPrint('Fetched all staff members: ${allStaff.length} items');
        debugPrint('First staff member: ${allStaff.isNotEmpty ? allStaff.first : 'None'}');
      }
    } catch (e) {
      debugPrint('Error fetching all staff members: $e');
    }
  }
  
  Future<void> _fetchLocations() async {
    try {
      final response = await APIRepository.getBusinessLocations();
      final locationsData = response['rows'] as List<dynamic>?;
      if (locationsData != null) {
        setState(() {
          allLocations = locationsData.cast<Map<String, dynamic>>();
        });
        debugPrint('Fetched all locations: ${allLocations.length} items');
        debugPrint('First location: ${allLocations.isNotEmpty ? allLocations.first : 'None'}');
      }
    } catch (e) {
      debugPrint('Error fetching all locations: $e');
    }
  }

  Future<void> submitServiceDetails() async {
    setState(() {
      isButtonDisabled = true;
    });

    try {
      List<Map<String, dynamic>> allDetails = [];
      
      for (var service in services) {
        final serviceId = service['category_id'];
        final formKey = formKeys[serviceId];
        if (formKey?.currentState != null) {
          final serviceDetailsWrapper = formKey!.currentState!.getServiceDetails();
          if (serviceDetailsWrapper != null && serviceDetailsWrapper['services'] != null) {
            final servicesList = serviceDetailsWrapper['services'] as List<Map<String, dynamic>>;
            allDetails.addAll(servicesList);
          }
        }
      }

      if (allDetails.isNotEmpty) {
        // Create the exact payload structure you specified
        final payload = {
            "details": allDetails
        };


        
        // Call your API service here
        debugPrint('Submitting service details payload: $payload');
        await APIRepository.postBusinessOfferings(payload: payload);
        // Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error submitting service details: $e');
    } finally {
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return OfferingsAddServiceScaffold(
        title: 'Service details',
        subtitle: 'Add details of your service below.',
        body: Center(
          child: Text(
            'No services found',
            style: AppTypography.bodyLg,
          ),
        ),
      );
    }

    // Check if any of the services are classes to determine title and subtitle
    final hasClassServices = services.any((service) => service['is_class'] == true);
    final title = hasClassServices ? 'Class details' : 'Service details';
    final subtitle = hasClassServices 
        ? "Now add your class details including the different sessions you're offering if it's more than one"
        : 'Add details of your service below.';

    // Group services by level, similar to onboarding screen
    final level1 = services.where((s) => (s['category_level'] ?? 1) == 1).toList();
    final level2 = services.where((s) => (s['category_level'] ?? 1) == 2).toList();

    final Map<String, List<dynamic>> level1ToLevel2 = {};
    for (var s in level2) {
      final parent = s['parent_id'];
      if (parent != null) {
        level1ToLevel2.putIfAbsent(parent, () => []).add(s);
      }
    }

    return OfferingsAddServiceScaffold(
      title: title,
      subtitle: subtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle level 1 and level 2 nesting like onboarding screen
          for (final l1 in level1) ...[
            Text(l1['title'] ?? 'Unknown Service', style: AppTypography.headingMd),
            const SizedBox(height: 8),
            if (level1ToLevel2.containsKey(l1['category_id']))
              // If level 2 exists, show only level 2 forms under level 1 heading
              for (final l2 in level1ToLevel2[l1['category_id']]!) ...[
                Text(l2['title'] ?? 'Unknown Service', style: AppTypography.headingSm),
                const SizedBox(height: 8),
                Builder(builder: (context) {
                  final key = GlobalKey<EnhancedServicesFormState>();
                  formKeys[l2['category_id']] = key;
                  return EnhancedServicesForm(
                    key: key,
                    serviceData: l2,
                    onDelete: () => _removeService(l2['category_id']),
                    staffMembers: allStaff,
                    locations: allLocations,
                  );
                }),
                const SizedBox(height: 16),
                // Note: "Add new" button is handled within the form for class services
                const SizedBox(height: 24),
              ]
            else ...[
              // If no level 2 exists, show level 1 form directly
              Builder(builder: (context) {
                final key = GlobalKey<EnhancedServicesFormState>();
                formKeys[l1['category_id']] = key;
                return EnhancedServicesForm(
                  key: key,
                  serviceData: l1,
                  onDelete: () => _removeService(l1['category_id']),
                  staffMembers: allStaff,
                  locations: allLocations,
                );
              }),
              const SizedBox(height: 16),
              // Add new service button for level 1 (only for non-class services)
              // if (l1['is_class'] != true) 
              //   _buildAddNewServiceButton(l1),
              const SizedBox(height: 24),
            ],
          ]
        ],
      ),
      bottomButton: PrimaryButton(
          text: 'Save',
          onPressed: isButtonDisabled ? null : submitServiceDetails,
          isDisabled: isButtonDisabled,
        ),
    );
  }

  void _removeService(String serviceId) {
    setState(() {
      services.removeWhere((service) => service['category_id'] == serviceId);
      formKeys.remove(serviceId);
    });
  }

  void _addNewService(Map<String, dynamic> templateService) {
    setState(() {
      final newService = Map<String, dynamic>.from(templateService);
      // Generate a unique ID for the new service
      newService['category_id'] = '${templateService['category_id']}_${DateTime.now().millisecondsSinceEpoch}';
      newService['title'] = ''; // Clear title for new service
      services.add(newService);
    });
  }

  Widget _buildAddNewServiceButton(Map<String, dynamic> serviceData) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _addNewService(serviceData),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.add_circle_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            "Add new ${serviceData['title'] ?? 'service'}",
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
