import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/services/socket_client.dart';
import 'package:frontend/services/token_manager.dart';
import 'package:frontend/view/addChat_screen.dart';
import 'package:frontend/view/auth_check.dart';
import 'package:frontend/view/app_shell.dart';
import 'package:frontend/view/createChat_screen.dart';
import 'package:frontend/view/mail_screen.dart';
import 'package:frontend/view/myCoop_screen.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';
import 'package:frontend/view/profile_screen.dart';
import 'package:frontend/view/resetPassword_screen.dart';
import 'package:frontend/view/signin_page.dart';
import 'package:frontend/view/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // load frontend config from .env
  await dotenv.load(fileName: ".env");  
  final apiClient = ApiClient();
  SocketClient.instance.init(apiClient);

  // initialize fcm, local notifs, and token saving
  // socket-dependent features are init later in _connectIfNeeded after socket connection is established
  await NotificationService.instance.initializeFcm(ApiClient());

  await _connectIfNeeded(); // eager connect before first frame to ensure socket is ready before load

  runApp(const MyApp());
}

const protectedRoutes = <String>{
  MailScreen.routeName,
  MyCoopScreen.routeName,
  ProfileScreen.routeName,
  ProfilePicSelectionScreen.routeName,
};

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Coop',
      debugShowCheckedModeBanner: false, //gets rid of the little red debug in the upper right corner
      home: const AuthCheck(),
      navigatorKey: navigatorKey,

      //styling
      theme: ThemeData(
        fontFamily: 'Zalando Sans', 
        // google fonts is no longer needed since the necessary fonts are bundled (assets/fonts)
        textTheme: const TextTheme( 
          bodyLarge: TextStyle(fontFamily: 'Zalando Sans'),
          bodyMedium: TextStyle(fontFamily: 'Zalando Sans'),
          bodySmall: TextStyle(fontFamily: 'Zalando Sans'),
          headlineLarge:  TextStyle(fontFamily: 'Seymour One'),
          headlineMedium: TextStyle(fontFamily: 'Seymour One'),
          headlineSmall:  TextStyle(fontFamily: 'Seymour One'),
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
        // ChatDetailScreen.routeName: (_) => RequireAuth(child: const ChatDetailScreen()),
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
      future: _connectIfNeeded(),
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

// check for session, connect socket if logged in
Future<bool> _connectIfNeeded() async {
  final loggedIn = await TokenManager.instance.hasSession();
  if (loggedIn) {
    await SocketClient.instance.connect();
    // once connected, set up socket-dependent notif listeners
    if (SocketClient.instance.isConnected) {
      NotificationService.instance.initializeSocket();
    } else {
      print('[_connectIfNeeded] socket failed to connect');
    }
    
  }
  return loggedIn;
}