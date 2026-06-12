import 'package:flutter/material.dart';
import '../services/socket_client.dart';
import '../services/token_manager.dart';
import 'app_shell.dart';
import 'mail_screen.dart';
import 'signup_page.dart';

class AuthCheck extends StatelessWidget {
  const  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = TokenManager.instance;

    return FutureBuilder<bool>(
      future: tokens.hasSession(), // refresh token exists?
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snap.data ?? false;

        // If session exists, go straight to "home" (just mail for now)
        if (loggedIn) {
          SocketClient.instance.connect(); // connect to socket on session restore
          return AppShell(currentRoute: MailScreen.routeName, child: MailScreen());
        }

        return const SignupPage();
      },
    );
  }
}