import 'package:bookit_mobile_app/app/theme/app_typography.dart';
import 'package:bookit_mobile_app/features/menu/widgets/menu_screens_scaffold.dart';
import 'package:bookit_mobile_app/shared/components/atoms/input_field.dart';
import 'package:flutter/material.dart';

class ClientWebAppScreen extends StatefulWidget {
  const ClientWebAppScreen({super.key});

  @override
  State<ClientWebAppScreen> createState() => _ClientWebAppScreenState();
}

class _ClientWebAppScreenState extends State<ClientWebAppScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  String _webAppLink = '';

  @override
  void initState() {
    super.initState();
    _businessNameController.text = 'StudioX';
    _updateWebAppLink(_businessNameController.text);
    
    _businessNameController.addListener(() {
      _updateWebAppLink(_businessNameController.text);
    });
  }

  void _updateWebAppLink(String businessName) {
    setState(() {
      final formattedName = businessName.toLowerCase().replaceAll(' ', '');
      _webAppLink = 'www.$formattedName.bookit-app.com';
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuScreenScaffold(
      title: "Client web app",
      subtitle: "You're all set! Creating your web app is now just a click away.",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox.shrink(),
          
          // Business name input section
          Text(
            "Confirm how you want your link to display by re-entering your business name here:",
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          InputField(hintText: "Enter your business name",
            controller: _businessNameController,
            onChanged: (value) => _updateWebAppLink(value),
          ),
          const SizedBox(height: 48),
          
          // Web app link preview section
          Text(
            "Your web app link will be",
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Generated web app link
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 84, horizontal: 24),
            child: Center(
              child: Text(
                _webAppLink,
                textAlign: TextAlign.center,
                style: AppTypography.headingSm.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  height: 24 / 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          
          const Spacer(),
        ],
      ),
      buttonText: "Go live",
      onButtonPressed: () {
        // Handle go live action
        // You can add navigation or API call here
        print('Going live with business name: ${_businessNameController.text}');
        print('Web app link: $_webAppLink');
        
        // Example: Navigate to success page or show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Web app is going live at $_webAppLink'),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}