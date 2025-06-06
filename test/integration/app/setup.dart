import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_foundation/shared_preferences_foundation.dart';

Future<void> setupIntegrationTests() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferencesPlatform.instance = SharedPreferencesFoundation();
  await SharedPreferencesPlatform.instance.clear();
}

class SharedPreferencesPlatform {
  static var instance;
}