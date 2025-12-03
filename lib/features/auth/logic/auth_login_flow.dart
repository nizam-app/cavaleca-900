import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/auth/model/auth_login_model.dart';

class InternalAuthRepository {
  final client = http.Client();

  Future<InternalLoginResponse> login({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse(AuthAPIController.technician_login);

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"phone": phone, "password": password}),
    );

    if (response.statusCode != 200) {
      throw Exception("Invalid credentials");
    }

    final jsonBody = jsonDecode(response.body);
    Logger().e(jsonBody["token"]);
    Logger().e(jsonBody["user"]);

    await AuthLocalStorage.saveLoginData(
      token: jsonBody['token'],
      userJson: jsonBody['user'],
    );
    return InternalLoginResponse.fromJson(jsonBody);
  }
}

class InternalAuthNotifier
    extends StateNotifier<AsyncValue<InternalLoginResponse?>> {
  InternalAuthNotifier(this._repo) : super(const AsyncValue.data(null));

  final InternalAuthRepository _repo;

  Future<void> login(String phone, String password) async {
    state = const AsyncValue.loading();

    try {
      final data = await _repo.login(phone: phone, password: password);

      // Save token locally
      final pref = await SharedPreferences.getInstance();
      await pref.setString("internal_token", data.token);

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final internalAuthRepositoryProvider = Provider(
  (ref) => InternalAuthRepository(),
);

final internalAuthProvider =
    StateNotifierProvider<
      InternalAuthNotifier,
      AsyncValue<InternalLoginResponse?>
    >((ref) => InternalAuthNotifier(ref.watch(internalAuthRepositoryProvider)));
