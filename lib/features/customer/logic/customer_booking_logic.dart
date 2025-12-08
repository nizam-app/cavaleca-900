import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/customer/model/customer_booking_model.dart';

class CustomerBookingLogic {
  static Future<String> _getToken() async {
    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      throw Exception('No auth token found');
    }
    return token;
  }

  /// GET /api/sr - Fetch all service requests for the customer
  static Future<List<CustomerBookingModel>> fetchBookings() async {
    final token = await _getToken();

    final url = Uri.parse(AuthAPIController.customerBookings);

    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to load bookings (${res.statusCode}): ${res.body}',
      );
    }

    final List<dynamic> data = jsonDecode(res.body);
    return CustomerBookingModel.listFromJson(data);
  }

  /// POST /api/sr/{{srId}}/book-again - Book again for completed SR
  static Future<void> bookAgain(int srId) async {
    final token = await _getToken();

    final url = Uri.parse(AuthAPIController.bookAgain(srId));

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to book again (${res.statusCode}): ${res.body}',
      );
    }
  }

  /// POST /api/sr/{{srId}}/rebook - Rebook for cancelled SR
  static Future<void> rebook(int srId) async {
    final token = await _getToken();

    final url = Uri.parse(AuthAPIController.rebook(srId));

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to rebook (${res.statusCode}): ${res.body}',
      );
    }
  }
}

