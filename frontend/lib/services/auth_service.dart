/*
  AuthService calls backend /auth endpoints.
  This service uses http.Client directly rather than ApiClient because these endpoints
  aren't protected (other than changePassword). ApiClient retries 401 responses using refresh(), so if AuthService
  used ApiClient, it would cause a circular loop. AuthService is the "lowest level" for auth endpoints.
*/

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'api_client.dart';
import 'token_manager.dart';

class AuthService {
  final http.Client _client;
  final TokenManager tokens;

  AuthService({http.Client? client, TokenManager? tokenManager})
    : _client = client ?? http.Client(),
      tokens = tokenManager ?? TokenManager.instance;

  // post auth/signup: creates a new user account
  // backend returns { message, userId, (devOnly)verificationUrl? }
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/auth/signup');

    final res = await _client.post(uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 5));

    // handle backend error details
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) return data;

    // shouldn't happen unless backend returns something unexpected
    throw Exception('Expected JSON object response');
  }

  // post auth/signin: logs the user in and returns session tokens
  // backend returns { accessToken, refreshToken, uid }
  Future<void> signin({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/auth/signin');
    
    final res = await _client.post(uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 5));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (access == null || refresh == null) {
      throw Exception('Missing tokens in response');
    }

    // save session tokens in local storage
    await tokens.saveTokens(accessToken: access, refreshToken: refresh);
  }

  // post auth/signout: logs the user out and revokes session tokens
  // returns 204 on success
  Future<void> logout() async {
    final refreshToken = await tokens.getRefreshToken();

    // clear fcm token from server so logged out user doesn't get notifs
    try {
      await ApiClient().postJson('/notifications/fcm-token', {'fcmToken': null});
    } catch(_) {}

    if (refreshToken != null && refreshToken.isNotEmpty) {
      final uri = Uri.parse('${Env.apiBaseUrl}/auth/signout');

      try {
        await _client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ 'refreshToken': refreshToken }),
        ).timeout(const Duration(seconds: 5));
      } catch(_) {
        // ignore logout errors, clear session tokens regardless
      }
    }
    await tokens.clearTokens();
  }

  // post auth/refresh: exchange valid refresh token for a new access token
  // client sends the refresh token and backend returns a new access token
  // called automatically by ApiClient whenever it receives a 401
  Future<void> refresh() async {
    print('Access token expired, calling refresh to generate new token');
    final refreshToken = await tokens.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available'); // indicates the session has expired or is invalid
    }

    final uri = Uri.parse('${Env.apiBaseUrl}/auth/refresh');

    final res = await _client.post(uri, 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    ).timeout(const Duration(seconds: 5));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final newAccess = data['accessToken'] as String?;
    if (newAccess == null || newAccess.isEmpty) {
      throw Exception('Missing accessToken in refresh response');
    }

    // only access tokens rotate on refresh; refresh token stays the same
    await tokens.saveTokens(accessToken: newAccess);
  }

  // patch auth/change-password: validate current password, then update with new password
  // this endpoint is protected, hence the fetch of access token
  // returns 204 on success
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('${Env.apiBaseUrl}/auth/change-password');

    Future<http.Response> doRequest() async {
      final access = await tokens.getAccessToken();
      return _client.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          if (access != null && access.isNotEmpty) 'Authorization': 'Bearer $access',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 5));
    }

    // try request normally
    var res = await doRequest();

    // if unauthorized, refresh and retry a single time
    if (res.statusCode == 401) {
      try {
        await tokens.refreshOnce(() => refresh());
        res = await doRequest();
      } catch(e) {
        await tokens.clearTokens();
        throw Exception("SESSION_EXPIRED");
      }
    }

    // if still not ok, throw
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}