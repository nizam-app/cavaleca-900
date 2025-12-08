import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';

class ProfileUpdateService {
  /// Update profile using PATCH /api/auth/profile
  /// Only sends fields that are provided (non-null)
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? status,
    List<String>? skills,
    List<Map<String, String>>? certifications,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
    String? mobileBankingType,
    String? mobileBankingNumber,
    String? businessHours,
  }) async {
    final token = await AuthLocalStorage.getToken();

    if (token == null) {
      throw Exception('No auth token found');
    }

    // Build request body with only non-null fields
    final Map<String, dynamic> body = {};

    if (name != null) body['name'] = name;
    if (status != null) body['status'] = status;
    if (skills != null) body['skills'] = skills;
    if (certifications != null) {
      body['certifications'] = certifications;
    }
    if (bankName != null) body['bankName'] = bankName;
    if (bankAccountNumber != null) body['bankAccountNumber'] = bankAccountNumber;
    if (bankAccountHolder != null) body['bankAccountHolder'] = bankAccountHolder;
    if (mobileBankingType != null) body['mobileBankingType'] = mobileBankingType;
    if (mobileBankingNumber != null) body['mobileBankingNumber'] = mobileBankingNumber;
    if (businessHours != null) body['businessHours'] = businessHours;

    final url = Uri.parse(AuthAPIController.profile);

    final response = await http.patch(
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
        'Failed to update profile (${response.statusCode}): $errorBody',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

