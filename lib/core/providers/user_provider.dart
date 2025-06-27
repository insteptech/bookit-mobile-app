import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/token_service.dart';
import '../../app/config.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception("No token");

    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch user");
    }
  }
}
