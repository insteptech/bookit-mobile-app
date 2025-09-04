import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/molecules/onboard_business_info_form.dart';
import 'package:flutter/material.dart';

class NameEmailPhoneScreen extends StatefulWidget {
  const NameEmailPhoneScreen({super.key});

  @override
  State<NameEmailPhoneScreen> createState() => _NameEmailPhoneScreenState();
}

class _NameEmailPhoneScreenState extends State<NameEmailPhoneScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  
  bool _isLoading = true; // Add loading state

  Future<void> _fetchBusinessDetails() async {
    try {
      setState(() {
        _isLoading = true; // Set loading to true
      });
      
      final String businessId = await ActiveBusinessService().getActiveBusiness() as String;
      final data = await UserService().fetchBusinessDetails(businessId: businessId);
      
      if (data != null) {
        nameController.text = data.name ?? '';
        emailController.text = data.email ?? '';
        mobileController.text = data.phone ?? '';
        websiteController.text = data.website ?? '';
      }
    } catch (error) {
      // Handle error if needed
      debugPrint('Error fetching business details: $error');
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when done
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBusinessDetails();
  }

  @override
  Widget build(BuildContext context) {
    return MenuScreenScaffold(
      title: "Name, Email, Phone",
      content: _isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loader while loading
            )
          : OnboardBusinessInfoForm(
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
              websiteController: websiteController,
              isDisabled: true,
              showHeading: false,
            ),
    );
  }
}