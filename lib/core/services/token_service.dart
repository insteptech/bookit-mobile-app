import 'package:bookit_mobile_app/core/services/shared_prefs_storage.dart';

import 'storage_interface.dart';

const _tokenKey = 'auth_token';

class TokenService {
  final StorageInterface _storage = SharedPrefsStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return await _storage.read(_tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(_tokenKey);
  }
}
