import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/customer_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/customer/screen/service/model/create_sr_model.dart';

class FsmCustomerApi {
  /// GET /api/categories  (token optional)
  static Future<List<FsmCategory>> fetchCategories() async {
    final token = await AuthLocalStorage.getToken();

    // common headers
    final headers = <String, String>{'Accept': 'application/json'};
    // jodi login thake tahole Authorization add
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final res = await http.get(
      Uri.parse(CustomerAPIController.categories),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load categories (${res.statusCode}): ${res.body}',
      );
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => FsmCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/sr  (token optional => guest allowed)
  static Future<void> createServiceRequest(
    ServiceRequestPayload payload,
  ) async {
    final token = await AuthLocalStorage.getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final res = await http.post(
      Uri.parse(CustomerAPIController.createSR),
      headers: headers,
      body: jsonEncode(payload.toJson()),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create SR (${res.statusCode}): ${res.body}');
    }
  }
}
