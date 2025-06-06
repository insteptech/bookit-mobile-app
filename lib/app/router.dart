import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/splash/presentation/splash_sceen.dart';
 
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);