import 'storage_interface.dart';
import 'shared_prefs_storage.dart';

const _activeBusinessKey = 'active_business';

class ActiveBusinessService {
  final StorageInterface _storage = SharedPrefsStorage();

  Future<void> saveActiveBusiness(String businessId) async {
    await _storage.write(_activeBusinessKey, businessId);
  }

  Future<String?> getActiveBusiness() async {
    return await _storage.read(_activeBusinessKey);
  }

  Future<void> clearActiveBusiness() async {
    await _storage.delete(_activeBusinessKey);
  }
}
