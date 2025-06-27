// import 'package:bookit_mobile_app/app/theme/theme_data.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       // ignore: use_build_context_synchronously
//       GoRouter.of(context).go('/login');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: lightTheme.scaffoldBackgroundColor,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.asset('assets/images/background.jpeg', fit: BoxFit.cover),
//           Center(
//             child: SvgPicture.asset(
//               'assets/images/logo.svg', 
//               width: 174.56,
//               height: 57.53,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:bookit_mobile_app/app/theme/theme_data.dart';
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

  Future<void> _checkAndRedirect() async {
  final prefs = ref.read(sharedPreferencesProvider);

  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return; // 💡 Check if still mounted

  final token = prefs.getString('auth_token');
  final step = prefs.getString('onboarding_step') ?? 'welcome';

  if (!mounted) return; // 💡 Double safety if prefs lookup was long

  if (token == null) {
    context.go('/login');
  } else {
    // switch (step) {
    //   case 'welcome': 
    //     context.go('/onboarding_welcome');
    //     break;
    //   case 'about':
    //     context.go('/onboarding_about');
    //     break;
    //   case 'location':
    //     context.go('/locations');
    //     break;
    //   case 'offerings':
    //     context.go('/offerings');
    //     break;
    //   default:
    //     context.go('/onboarding_welcome');
    // }
    context.go('/onboarding_welcome');
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
