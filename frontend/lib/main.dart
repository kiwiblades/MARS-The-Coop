import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/view/app_shell.dart';
import 'package:frontend/view/mail_screen.dart';
import 'package:frontend/view/myCoop_screen.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';
import 'package:frontend/view/profile_screen.dart';
// import 'services/api_client.dart';
// import 'services/health_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load frontend config from .env
  await dotenv.load(fileName: ".env");  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Backend test',
      debugShowCheckedModeBanner: false, //gets rid of the little red debug in the upper right corner
      initialRoute: MailScreen.routeName, //no home page, Mail will be initial
      //can have theme
      routes: {
        MailScreen.routeName: (BuildContext context) => const AppShell(child: MailScreen()),
        MyCoopScreen.routeName: (BuildContext context) => const AppShell(child: MyCoopScreen()),
        ProfileScreen.routeName: (BuildContext context) => const AppShell(child: ProfileScreen()), //TODO: user must be passed i.e. ProfileScreen(user)
        ProfilePicSelectionScreen.routeName: (BuildContext context) => const ProfilePicSelectionScreen(),
      },
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
