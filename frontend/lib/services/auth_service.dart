/*
  AuthService calls backend /auth endpoints
*/

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'token_manager.dart';

class AuthService {
  final http.Client _client;
  final TokenManager tokens;

  AuthService({http.Client? client, TokenManager? tokenManager})
    : _client = client ?? http.Client(),
      tokens = tokenManager ?? TokenManager.instance;

    // post auth/login
    Future<void> login() async {
      // to be implemented
    }

    // post auth/refresh
    // client sends the refresh token and backend returns a new access token
    Future<void> refresh() async {
      final refreshToken = await tokens.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available'); // indicates the session has expired or is invalid
      }

      final uri = Uri.parse('${Env.apiBaseUrl}/auth/refresh');

      final res = await _client.post(uri, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken' : refreshToken}),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String;

      await tokens.saveTokens(accessToken: newAccess);
    }

    // post auth/logout
    Future<void> logout() async {
      // to be implemented
      await tokens.clearTokens();
    }
}