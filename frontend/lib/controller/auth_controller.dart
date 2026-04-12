import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/services/socket_client.dart';

class AuthController {
  final AuthService auth;
  
  AuthController({required this.auth});
  
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final data = await auth.signup(username: username, email: email, password: password);
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signin({
    required String username,
    required String password,
  }) async {
    try {
      await auth.signin(username: username, password: password);
      await NotificationService.instance.saveToken(); // save the fcm token for notifications
      await SocketClient.instance.connect(); // establish connection with socket once tokens are saved
      return {'success': true}; // tokens are saved locally inside AuthService
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}