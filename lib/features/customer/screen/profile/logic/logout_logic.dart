import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/services/realtime_service.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/shared/realtime_location_service.dart';

class CustomerLogOut {
  static Future<void> logout() async {
    // Stop real-time location updates before logout
    RealtimeLocationService().stop();

    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      // locally kono login data nai, just return
      return;
    }

    final url = Uri.parse(AuthAPIController.logout);

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Logout failed (${res.statusCode})');
    }

    // optional: response dekhte chaile
    final data = jsonDecode(res.body);
    debugPrint('logout => $data');

    // success hole local data clear
    // Disconnect realtime socket before clearing token
    RealtimeService().disconnect();
    await AuthLocalStorage.clearLoginData();
  }
}
