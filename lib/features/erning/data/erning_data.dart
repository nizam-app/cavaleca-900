import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:workpleis/core/constants/api_control/auth_api.dart';
import 'package:workpleis/core/utils/global_save_login_data.dart';
import 'package:workpleis/features/erning/model/erninig_model.dart';
import 'package:workpleis/features/erning/model/freelancer_transaction.dart';

final freelancerEarningsProvider = FutureProvider<FreelancerEarningsData>((
  ref,
) async {
  final summary = await TechnicianEarningsApi.fetchEarnings();
  return FreelancerEarningsData.fromSummary(summary);
});
final internalEarningsProvider = FutureProvider<TechnicianEarningsSummary>((
  ref,
) async {
  return TechnicianEarningsApi.fetchEarnings();
});

class TechnicianEarningsApi {
  static Future<TechnicianEarningsSummary> fetchEarnings() async {
    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      throw Exception('No auth token found (please login first).');
    }

    final res = await http.get(
      Uri.parse(AuthAPIController.technician_earnings),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load technician earnings (${res.statusCode}): ${res.body}',
      );
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return TechnicianEarningsSummary.fromJson(jsonMap);
  }

  /// POST /api/commissions/payout-request
  ///
  /// Body:
  /// {
  ///   "amount": 100,
  ///   "reason": "Need funds for expenses",
  ///   "paymentMethod": "BANK_ACCOUNT"
  /// }
  static Future<void> requestEarlyPayout({
    required double amount,
    required String reason,
    required String paymentMethod,
  }) async {
    final token = await AuthLocalStorage.getToken();
    if (token == null) {
      throw Exception('No auth token found (please login first).');
    }

    final uri = Uri.parse(AuthAPIController.technician_payout_request);

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'reason': reason,
        'paymentMethod': paymentMethod,
      }),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      String errorMessage =
          'Failed to request payout (${res.statusCode}). Please try again.';

      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          final backendMessage = decoded['message'];
          if (backendMessage is String && backendMessage.trim().isNotEmpty) {
            errorMessage = backendMessage;
          }
        }
      } catch (_) {
        // Ignore JSON parse errors and fall back to the default message
      }

      throw Exception(errorMessage);
    }
  }
}
