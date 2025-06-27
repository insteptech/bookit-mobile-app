import 'storage_interface.dart';
import 'shared_prefs_storage.dart';

const _onboardingKey = 'onboarding_step';

class OnboardingService {
  final StorageInterface _storage = SharedPrefsStorage();

  Future<void> saveStep(String step) async {
    await _storage.write(_onboardingKey, step);
  }

  Future<String?> getStep() async {
    return await _storage.read(_onboardingKey);
  }

  Future<void> clearStep() async {
    await _storage.delete(_onboardingKey);
  }
}
