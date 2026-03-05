import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/token_manager.dart';
import 'package:frontend/view/auth_check.dart';
import 'package:frontend/view/app_shell.dart';
import 'package:frontend/view/mail_screen.dart';
import 'package:frontend/view/mycoop_screen.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';
import 'package:frontend/view/profile_screen.dart';
import 'package:frontend/view/signin_page.dart';
import 'package:frontend/view/signup_page.dart';
import 'package:frontend/view/chat_page.dart';
import 'theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load frontend config from .env
  await dotenv.load(fileName: ".env");  
  runApp(const MyApp());
}

const protectedRoutes = <String>{
  MailScreen.routeName,
  MyCoopScreen.routeName,
  ProfileScreen.routeName,
  ProfilePicSelectionScreen.routeName,
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Coop',
      debugShowCheckedModeBanner: false, //gets rid of the little red debug in the upper right corner
      theme: buildAppTheme(), 
      home: const AuthCheck(),

      routes: {
        // public
        SignupPage.routeName: (_) => const SignupPage(),
        SigninPage.routeName: (_) => const SigninPage(),

        // protected
        MailScreen.routeName: (_) => RequireAuth(child: AppShell(child: MailScreen())),
        MyCoopScreen.routeName: (_) => RequireAuth(child: AppShell(child: MyCoopScreen())),
        ProfileScreen.routeName: (_) => RequireAuth(child: AppShell(child: ProfileScreen())),
        ProfilePicSelectionScreen.routeName: (_) => RequireAuth(child: const ProfilePicSelectionScreen()),
        ChatPage.routeName: (_) => RequireAuth(
          child: AppShell(
            child: ChatPage(chatId: 1, currentUserId: 123),  // Hardcoded test values
          ),
        ),
      },
    );
  }
}

class RequireAuth extends StatelessWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: TokenManager.instance.hasSession(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snap.data ?? false;
        if (!loggedIn) return const SigninPage();

        return child;
      },
    );
  }
}