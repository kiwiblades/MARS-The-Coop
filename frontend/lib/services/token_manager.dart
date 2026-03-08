/*
  This class ensures there is only one instance managing tokens throughout the app
  by using the Singleton desgin pattern. The default constructor is private, so other objects
  can't create an instance.
*/

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  static TokenManager get instance => _instance; // getter for TokenManager instance

  late FlutterSecureStorage _secureStorage;

  TokenManager._internal() {
    _secureStorage = const FlutterSecureStorage();
  }

  // keys used to store values in secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // track in-progress refresh so multiple requests don't spam /auth/refresh
  Future<void>? _refreshInFlight;

  // read current access token + current refresh token
  Future<String?> getAccessToken() => _secureStorage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _secureStorage.read(key: _refreshTokenKey);

  Future<bool> hasSession() async {
    final refresh = await getRefreshToken();
    // print('User has active session?: ${refresh != null && refresh.isNotEmpty}');
    return refresh != null && refresh.isNotEmpty;
  }

  // set an access token, but refresh tokens are only set on login
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    print('Saved access token locally');

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      print('Saved refresh token locally');
    }
  }

  // clear tokens on logout or if refresh expires
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // ensure only one refresh happens at a time
  Future<void> refreshOnce(Future<void> Function() refreshFn) {
    _refreshInFlight ??= refreshFn().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }
}