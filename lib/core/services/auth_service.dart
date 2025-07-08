import 'dart:convert';

import 'package:bookit_mobile_app/core/models/user_model.dart';

import 'storage_interface.dart';
import 'shared_prefs_storage.dart';

class AuthStorageService {
  final StorageInterface _storage = SharedPrefsStorage();

  Future<void> saveUserDetails(UserModel user) async {
  final jsonString = jsonEncode(user.toJson()); // convert map to string
  await _storage.write("userDetails", jsonString);
}


  Future<String?> getUserDetails() async {
    return await _storage.read("userDetails");
  }

  Future<void> clearUserDetails() async {
    await _storage.delete("userDetails");
  }
}
