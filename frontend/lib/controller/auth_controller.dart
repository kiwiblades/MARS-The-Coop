import '../services/api_client.dart';
import '../model/user.dart';

class AuthController {
  final ApiClient _apiClient;
  
  AuthController(this._apiClient);
  
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    // API call
    try {
      final response = await _apiClient.post('/auth/signup', {
        'username': username,
        'email': email,
        'password': password,
      });
      return {'success': true, 'user': User.fromJson(response)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  Future<Map<String, dynamic>> signin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post('/auth/signin', {
        'username': username,
        'password': password,
      });
      return {'success': true, 'user': User.fromJson(response)};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}