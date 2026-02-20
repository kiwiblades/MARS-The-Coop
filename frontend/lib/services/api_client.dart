/*
  Wrapper for HTTP requests. Keeps URL building, timeout, and error handling separately in one place.
  Services should call this rather than using http directly.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // compose the full url from apiBaseUrl + path
  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    final res = await _client.get(uri).timeout(const Duration(seconds: 5)); // timeout prevents infinite spin in UI

    // throws an exception on non-2xx (error codes) so UI can display clearly
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 5));
    
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}