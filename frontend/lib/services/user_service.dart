/*
  UserService calls backend /user endpoints.
  This service depends on ApiClient rather than http.Client directly so that
  the authorization header is automatically attached, and the 401 response triggers
  refresh and retry one time.
*/

import 'api_client.dart';
import '../model/profile_model.dart';

class UserService {
  final ApiClient api;
  UserService({required this.api});

  // get /user
  // returns: { user: { uid, username, email, emailVerified, emailVerifiedAt, pigeonId }}
  Future<User> getProfile() async {
    final data = await api.getJson('/user');
    final userJson = data['user'] as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  // patch /user
  // updates user and/or email and/or pigeonid (pfp)
  Future<User> updateProfile({
    String? username,
    String? email,
    int? pigeonId,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (pigeonId != null) body['pigeonId'] = pigeonId;

    if (body.isEmpty) {
      throw Exception('No fields to update');
    }

    final data = await api.patchJson('/user', body);
    final userJson = data['user'] as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  // post /auth/signout
  // server invalidates the JWT
  // returns 200 OK
  Future<void> signout() async {
    final refreshToken = await api.tokens.getRefreshToken();
    // We use the api client to hit your backend logout route
    // Note: ensure the path matches your backend (e.g., '/auth/logout' or '/api/auth/logout')
    await api.postJson('/auth/signout', {'refreshToken': refreshToken ?? ''});
    await api.tokens.clearTokens(); // clear local tokens after signout
  }
}
