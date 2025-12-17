import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/core/services/fcm_service.dart';
import 'package:workpleis/features/auth/model/d.dart';

class RegistrationApi {
  /// 1) POST /api/otp/send
  static Future<SendOtpResponse> sendRegistrationOtp({
    required String phone,
    required String name,
    required String role, // "CUSTOMER" | "TECH_FREELANCER" | "TECH_INTERNAL"
  }) async {
    final res = await http.post(
      Uri.parse(AuthAPIController.sendOTP), // => {{baseUrl}}/api/otp/send
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'name': name,
        'type': 'REGISTRATION',
        'role': role,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send OTP (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return SendOtpResponse.fromJson(data);
  }

  /// 2) POST /api/otp/verify
  static Future<VerifyOtpResponse> verifyRegistrationOtp({
    required String phone,
    required String code,
    required String tempToken,
  }) async {
    final res = await http.post(
      Uri.parse(
        AuthAPIController.numberVerify,
      ), // => {{baseUrl}}/api/otp/verify
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'type': 'REGISTRATION',
        'tempToken': tempToken,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to verify OTP (${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return VerifyOtpResponse.fromJson(data);
  }

  /// 3) POST /api/auth/set-password
  static Future<SetPasswordResponse> setPassword({
    required String phone,
    required String password,
    required String tempToken,
    required String role, // future এ চাইলে দরকার হলে body তে পাঠাতে পারো
    Map<String, dynamic>? extra, // employeeId ইত্যাদি লাগলে
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'password': password,
      'tempToken': tempToken,
      if (extra != null) ...extra,
    };

    final res = await http.post(
      Uri.parse(
        AuthAPIController.set_password,
      ), // => {{baseUrl}}/api/auth/set-password
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) {
      throw Exception(
        'Failed to complete registration (${res.statusCode}): ${res.body}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    // 🔐 এখানে local storage এ token + user save কোরো
    await AuthLocalStorage.saveLoginData(
      token: data['token'],
      userJson: data['user'],
    );

    // Initialize FCM and register token after successful registration
    await FCMService.initialize();

    return SetPasswordResponse.fromJson(data);
  }
}
