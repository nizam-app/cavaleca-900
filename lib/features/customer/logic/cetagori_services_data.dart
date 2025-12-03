import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:workpleis/features/customer/model/service_category_model.dart';

// nijer baseUrl use koro
const String kBaseUrl = 'https://your-api-domain.com';

// jodi token lagay (auth), header-e add kore dio
Future<Map<String, String>> _defaultHeaders({String? token}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
}

/// GET /api/categories
Future<List<ServiceCategory>> fetchServiceCategories({String? token}) async {
  final uri = Uri.parse('$kBaseUrl/api/categories');
  final headers = await _defaultHeaders(token: token);

  final resp = await http.get(uri, headers: headers);

  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    return ServiceCategory.listFromJson(resp.body);
  } else {
    throw Exception(
      'Failed to load categories (${resp.statusCode}): ${resp.body}',
    );
  }
}

/// POST /api/sr
Future<void> createServiceRequest(
  ServiceRequestPayload payload, {
  String? token,
}) async {
  final uri = Uri.parse('$kBaseUrl/api/sr');
  final headers = await _defaultHeaders(token: token);

  final resp = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(payload.toJson()),
  );

  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    throw Exception(
      'Failed to create service request (${resp.statusCode}): ${resp.body}',
    );
  }
}
