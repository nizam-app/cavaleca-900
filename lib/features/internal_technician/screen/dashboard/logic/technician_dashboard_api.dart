import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/internal_technician/screen/dashboard/model/technician_dashboard_model.dart';

class TechnicianDashboardApi {
  static Future<String> _getToken() async {
    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      throw Exception('No auth token found');
    }
    return token;
  }

  /// GET /api/technician/dashboard
  static Future<TechnicianDashboardModel> fetchDashboard() async {
    final token = await _getToken();

    final url = Uri.parse(AuthAPIController.technician_dashboard);

    final res = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load dashboard [${res.statusCode}]: ${res.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    return TechnicianDashboardModel.fromJson(data);
  }
}

