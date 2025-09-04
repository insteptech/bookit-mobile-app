import 'package:bookit_mobile_app/features/auth/application/controllers/login_controller.dart';
import 'package:bookit_mobile_app/features/auth/application/controllers/social_login_controller.dart';
import 'package:bookit_mobile_app/features/auth/application/state/login_state.dart';
import 'package:bookit_mobile_app/features/auth/application/state/social_login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = StateNotifierProvider<LoginController, LoginState>(
  (ref) => LoginController(),
);

final socialLoginProvider = StateNotifierProvider<SocialLoginController, SocialLoginState>(
  (ref) => SocialLoginController(),
);

final rememberMeProvider = StateProvider<bool>((ref) => false);
