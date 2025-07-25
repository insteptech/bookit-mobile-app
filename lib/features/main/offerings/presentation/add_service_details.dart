import 'package:bookit_mobile_app/features/main/offerings/widgets/add_service_details_form.dart';
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

  @override
  void initState() {
    super.initState();
    final servicesData = widget.servicePayload?['services'] as List<dynamic>?;
    if (servicesData != null) {
      services = servicesData.cast<Map<String, dynamic>>();
    }
    print('Services: $services');
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
          final serviceDetails = formKey!.currentState!.getServiceDetails();
          if (serviceDetails != null) {
            allDetails.add(serviceDetails);
          }
        }
      }

      if (allDetails.isNotEmpty) {
        // Call your API service here
        print('Submitting all service details: $allDetails');
        // await YourApiService().submitServiceDetails({'data': {'details': allDetails}});
        
        // Navigate back or to next screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error submitting service details: $e');
    } finally {
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Wellness services details',
          style: AppTypography.headingLg.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: services.isEmpty
          ? Center(
              child: Text(
                'No services found',
                style: AppTypography.bodyLg,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add details of your service below.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create a form for each service
                        for (final service in services) ...[
                          SizedBox(height: 16),
                          
                          // Service title as heading
                          Text(
                            service['title'] ?? 'Unknown Service',
                            style: AppTypography.headingMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Enhanced service form
                          Builder(
                            builder: (context) {
                              final key = GlobalKey<EnhancedServicesFormState>();
                              formKeys[service['category_id']] = key;
                              return EnhancedServicesForm(
                                key: key,
                                serviceData: service,
                              );
                            },
                          ),
                          SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Save button
                Container(
                  padding: EdgeInsets.all(20),
                  child: PrimaryButton(
                    text: 'Save',
                    onPressed: isButtonDisabled ? null : submitServiceDetails,
                    isDisabled: isButtonDisabled,
                  ),
                ),
              ],
            ),
    );
  }
}