import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/customer/screen/profile/model/Custom_profile_model.dart';

class CustomerProfileApi {
  static Future<CustomerProfile> getProfile() async {
    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final uri = Uri.parse(AuthAPIController.profile);

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Profile load failed (${res.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    return CustomerProfile.fromJson(data);
  }
}
