import 'package:flutter/material.dart';
import 'package:frontend/services/socket_client.dart';
import 'package:frontend/services/token_manager.dart';
import 'package:frontend/view/app_shell.dart';
import 'package:frontend/view/mail_screen.dart';
import 'package:frontend/view/signup_page.dart';

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
          return AppShell(child: MailScreen(), currentRoute: MailScreen.routeName);
        }

        return const SignupPage();
      },
    );
  }
}