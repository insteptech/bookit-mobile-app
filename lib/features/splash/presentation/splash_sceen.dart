import 'package:bookit_mobile_app/app/theme/theme_data.dart';
import 'package:bookit_mobile_app/core/services/active_business_service.dart';
import 'package:bookit_mobile_app/core/services/remote_services/network/auth_api_service.dart';
import 'package:bookit_mobile_app/core/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shared_pref_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRedirect();
  }

  void logout()async{
    await TokenService().clearToken();
    if(mounted){
      context.go("/login");
    }
  }

  Future<void> _checkAndRedirect() async {
  final prefs = ref.read(sharedPreferencesProvider);

  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return; 

  final token = prefs.getString('auth_token');
  final step = prefs.getString('onboarding_step') ?? 'welcome';

  if (!mounted) return; 

  if (token == null) {
    context.go('/login');
  } else {
     final userService = UserService();
     final user = await userService.fetchUserDetails();

      if(user.businessIds.isNotEmpty){
        final businessData = await userService.fetchBusinessDetails(businessId: user.businessIds[0]);

        if(businessData.isOnboardingComplete){
          await ActiveBusinessService().saveActiveBusiness(user.businessIds[0]);
          context.go("/home_screen");
        } else {
          context.go('/onboarding_welcome');
        }
      }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightTheme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpeg', fit: BoxFit.cover),
          Center(
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              width: 174.56,
              height: 57.53,
            ),
          ),
        ],
      ),
    );
  }
}
