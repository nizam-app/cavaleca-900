import 'dart:convert';

import 'package:http/http.dart' as http;

class CommissionApi {
  static Future<Map<String, dynamic>> requestPayout({
    required String baseUrl,
    required String? token,
    required PayoutRequestPayload payload,
  }) async {
    final uri = Uri.parse('$baseUrl/api/commissions/payout-request');

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
        // যদি আপনার API তে Bearer লাগে:
        // if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload.toJson()),
    );

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    final msg = (data['message'] ?? data['error'] ?? res.body).toString();
    throw Exception(msg);
  }
}

class PayoutRequestPayload {
  final num amount;
  final String reason;
  final String paymentMethod; // "BANK_ACCOUNT"

  PayoutRequestPayload({
    required this.amount,
    required this.reason,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "reason": reason,
    "paymentMethod": paymentMethod,
  };
}
