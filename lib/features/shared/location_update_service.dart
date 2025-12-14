import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';

class LocationUpdateService {
  /// Update location status using POST /api/location/update
  /// status should be "ONLINE" or "OFFLINE"
  static Future<Map<String, dynamic>> updateLocationStatus({
    required String status,
    double? latitude,
    double? longitude,
  }) async {
    final token = await AuthLocalStorage.getToken();

    if (token == null) {
      throw Exception('No auth token found');
    }

    // Build request body
    final Map<String, dynamic> body = {
      'status': status,
    };

    // Add optional latitude and longitude if provided
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    final url = Uri.parse(AuthAPIController.locationUpdate);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = response.body;
      throw Exception(
        'Failed to update location status (${response.statusCode}): $errorBody',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
