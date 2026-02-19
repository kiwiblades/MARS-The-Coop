/*
  Wrapper for HTTP requests. Keeps URL building, timeout, and error handling separately in one place.
  Services should call this rather than using http directly.
*/

import 'dart:convert';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/token_manager.dart';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiClient {
  final http.Client _client;
  final TokenManager tokens;
  final AuthService auth;

  ApiClient({http.Client? client, TokenManager? tokenManager, AuthService? authService}) 
    : _client = client ?? http.Client(),
      tokens = tokenManager ?? TokenManager.instance,
      auth = authService ?? AuthService(client: client, tokenManager: tokenManager);

  // // compose the full url from apiBaseUrl + path
  // Future<Map<String, dynamic>> getJson(String path) async {
  //   final uri = Uri.parse('${Env.apiBaseUrl}$path');
  //   final res = await _client.get(uri).timeout(const Duration(seconds: 5)); // timeout prevents infinite spin in UI

  //   // throws an exception on non-2xx (error codes) so UI can display clearly
  //   if (res.statusCode < 200 || res.statusCode >= 300) {
  //     throw Exception('HTTP ${res.statusCode}: ${res.body}');
  //   }
  //   return jsonDecode(res.body) as Map<String, dynamic>;
  // }

    Future<Map<String, dynamic>> getJson(String path) {
      return _sendJson('GET', path);
    }

    Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) {
      return _sendJson('POST', path, body: body);
    }

    Future<Map<String, dynamic>> _sendJson(String method, String path, {Map<String, dynamic>? body}) async {
      final uri = Uri.parse('${Env.apiBaseUrl}$path');

      Future<http.Response> doRequest() async {
        final access = await tokens.getAccessToken();

        // compose the headers by adding the access token, which the backend uses to verify authenticity
        final headers = <String, String> {
          'Content-Type': 'application/json',
          if (access != null && access.isNotEmpty) 'Authorization': 'Bearer $access',
        };

        switch(method) {
          case 'GET':
            return _client.get(uri, headers: headers).timeout(const Duration(seconds: 5));
          case 'POST':
            return _client.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(const Duration(seconds: 5));
          default:
            throw Exception('Unsupported method: $method');
        }
      }

      // try request normally
      var res = await doRequest();

      // if unauthorized, refresh and retry a single time
      if (res.statusCode == 401) {
        try {
          await tokens.refreshOnce(() => auth.refresh());
          res = await doRequest();
        } catch(e) {
          await tokens.clearTokens(); // if refresh token is expired, session info should be cleared
          throw Exception("SESSION_EXPIRED");
        }
      }

      // if still not ok, throw
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      // parse the json from the response
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Expected JSON object response');
    }
}