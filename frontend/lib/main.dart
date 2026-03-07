import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/controller/createChat_controller.dart';
import 'package:frontend/services/token_manager.dart';
import 'package:frontend/view/addChat_screen.dart';
import 'package:frontend/view/auth_check.dart';
import 'package:frontend/view/app_shell.dart';
import 'package:frontend/view/createChat_screen.dart';
import 'package:frontend/view/mail_screen.dart';
import 'package:frontend/view/mycoop_screen.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';
import 'package:frontend/view/profile_screen.dart';
import 'package:frontend/view/resetPassword_screen.dart';
import 'package:frontend/view/signin_page.dart';
import 'package:frontend/view/signup_page.dart';
import 'package:frontend/view/chat_page.dart';

import 'package:google_fonts/google_fonts.dart';

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
    const darkBrown = Color(0xFF93633A);
    return MaterialApp(
      title: 'The Coop',
      debugShowCheckedModeBanner: false, //gets rid of the little red debug in the upper right corner
      home: const AuthCheck(),

      //styling
      theme: ThemeData(
        fontFamily: 'Zalando Sans', 

        textTheme: GoogleFonts.seymourOneTextTheme().copyWith(
          bodyLarge: const TextStyle(fontFamily: 'Zalando Sans'),
          bodyMedium: const TextStyle(fontFamily: 'Zalando Sans'),
          bodySmall: const TextStyle(fontFamily: 'Zalando Sans'),
        ),
      ),

      routes: {
        // public
        SignupPage.routeName: (_) => const SignupPage(),
        SigninPage.routeName: (_) => const SigninPage(),

        // protected
        MailScreen.routeName: (_) => RequireAuth(child: AppShell(child: MailScreen(), currentRoute: MailScreen.routeName)),
        MyCoopScreen.routeName: (_) => RequireAuth(child: AppShell(child: MyCoopScreen(), currentRoute: MyCoopScreen.routeName)),
        ProfileScreen.routeName: (_) => RequireAuth(child: AppShell(child: ProfileScreen(), currentRoute: ProfileScreen.routeName)),
        ProfilePicSelectionScreen.routeName: (_) => RequireAuth(child: const ProfilePicSelectionScreen()),
        
        ResetPasswordScreen.routeName: (_) => RequireAuth(child: const ResetPasswordScreen()),
        AddChatScreen.routeName: (_) => RequireAuth(child: const AddChatScreen()),
        CreateChatScreen.routeName: (_) => RequireAuth(child: const CreateChatScreen()),
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