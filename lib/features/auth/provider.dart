import 'package:bookit_mobile_app/features/auth/applications/login_controller.dart';
import 'package:bookit_mobile_app/features/auth/applications/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = StateNotifierProvider<LoginController, LoginState>(
  (ref) => LoginController(),
);

final rememberMeProvider = StateProvider<bool>((ref) => false);
