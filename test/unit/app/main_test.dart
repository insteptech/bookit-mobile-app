import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bookit_mobile_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel orientationChannel = MethodChannel('flutter/platform');
  const MethodChannel sharedPrefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      sharedPrefsChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, Object>{};
        }
        return true;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      orientationChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'SystemChrome.setPreferredOrientations':
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          case 'SystemChrome.setSystemUIOverlayStyle':
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sharedPrefsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(orientationChannel, null);
  });

  testWidgets('bootstrap runs without errors', (tester) async {
    await bootstrap();
    expect(true, isTrue);
  });
}