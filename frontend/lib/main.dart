import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/token_manager.dart';
import 'view/signup_page.dart';
import 'package:frontend/view/app_shell.dart';
import 'package:frontend/view/mail_screen.dart';
import 'package:frontend/view/mycoop_screen.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';
import 'package:frontend/view/profile_screen.dart';


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
    final tokens = TokenManager.instance;

    return MaterialApp(
      title: 'The Coop',
      debugShowCheckedModeBanner: false, //gets rid of the little red debug in the upper right corner
      initialRoute: SignupPage.routeName, // start an signup(?)

      onGenerateRoute: (settings) {
        final name = settings.name ?? SignupPage.routeName;

        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return FutureBuilder(future: tokens.hasSession(), // check that refresh token exists 
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final loggedIn = snap.data ?? false;
                final needsAuth = protectedRoutes.contains(name);

                if (needsAuth && !loggedIn) {
                  return const SignupPage();
                }

                switch (name) {
                  case SignupPage.routeName:
                    return const SignupPage();
                  case MailScreen.routeName:
                    return AppShell(child: MailScreen());
                  case MyCoopScreen.routeName:
                    return AppShell(child: MyCoopScreen());
                  case ProfileScreen.routeName:
                    return AppShell(child: ProfileScreen());
                  case ProfilePicSelectionScreen.routeName:
                    return const ProfilePicSelectionScreen();
                  default:
                    return const SignupPage();
                }
              },
            );
          },
        );
      }

      // //can have theme
      // routes: {
      //   MailScreen.routeName: (BuildContext context) => AppShell(child: MailScreen()),
      //   MyCoopScreen.routeName: (BuildContext context) => AppShell(child: MyCoopScreen()),
      //   ProfileScreen.routeName: (BuildContext context) => AppShell(child: ProfileScreen()), //TODO: user must be passed i.e. ProfileScreen(user)
      //   ProfilePicSelectionScreen.routeName: (BuildContext context) => const ProfilePicSelectionScreen(),
      // },
    );
  }
}

// entry point to prove the mobile app can reach the backend -- feel free to remove/comment out
// class HealthPage extends StatefulWidget {
//   const HealthPage({super.key});
//   @override
//   State<HealthPage> createState() => _HealthPageState();
// }

// class _HealthPageState extends State<HealthPage> {
//   late final HealthService _healthService;
//   late Future<Map<String, dynamic>> _future;

//   @override
//   void initState() {
//     super.initState();
//     _healthService = HealthService(ApiClient());
//     _future = _healthService.fetchHealth(); // run immediately on page load
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Backend connectivity test')),
//       body: Center(
//         child: FutureBuilder<Map<String, dynamic>>(
//           future: _future,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             }
//             final data = snapshot.data!;
//             return Text('${data['message']}');
//           }
//         )
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => setState(() => _future = _healthService.fetchHealth()),
//         child: const Icon(Icons.refresh)
//       ),
//     );
//   }
// }
