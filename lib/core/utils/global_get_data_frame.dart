// Dart imports:
import 'dart:convert';
// Package imports:
import 'package:http/http.dart' as http;

class GlobalGetDataFrame {
  /// [uri] = API URL
  /// [key] = JSON key (e.g., "slider", "data", "users")
  /// [fromJson] = function that converts each item to a model
  static Future<List<T>> getDataFrame<T>(
      String uri, {
        required String key,
        required T Function(Map<String, dynamic>) fromJson,
      }) async {
    final url = Uri.parse(uri);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      if (!json.containsKey(key)) {
        throw Exception("Key '$key' not found in response");
      }

      final List data = json[key];
      return data.map((e) => fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
