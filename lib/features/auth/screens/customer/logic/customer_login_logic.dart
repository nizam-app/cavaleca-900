import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/auth/screens/customer/model/customer_login_model.dart';

class CustomerAuthApi {
  static const String _baseUrl =
      'https://outside1backend.mtscorporate.com/users';

  static Future<CustomerOtpSendResponse> sendLoginOtp(String phone) async {
    final url = Uri.parse(AuthAPIController.sendOTP);

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'type': 'LOGIN'}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send OTP (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    debugPrint('sendOtp => $data');

    return CustomerOtpSendResponse.fromJson(data);
  }

  static Future<void> verifyLoginOtp({
    required String phone,
    required String code,
  }) async {
    final url = Uri.parse(AuthAPIController.numberVerify);

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code, 'type': 'LOGIN'}),
    );

    if (res.statusCode != 200) {
      throw Exception('Invalid OTP');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    debugPrint('verifyOtp => $data');

    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    // ⬇️ tumi je helper diecho, ota diye save
    await AuthLocalStorage.saveLoginData(token: token, userJson: userJson);
  }
}
