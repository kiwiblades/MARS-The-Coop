import 'package:flutter/material.dart';
import 'package:frontend/controller/appshell_controller.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final AppShellController controller;
  AppShell({super.key, required this.child, required this.currentRoute}) : controller = AppShellController();
  
  @override
  Widget build(BuildContext context) {
    TextStyle tabStyle(BuildContext context, String route) {
  bool active = currentRoute == route;

  return active
      ? Theme.of(context).textTheme.headlineSmall!.copyWith(
          color: Color(0xFF93633A),
      )
      : Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Color(0xFF93633A),
        );
}
    return Scaffold(
      backgroundColor: Color(0xFFD1A681),
      appBar: AppBar(
      backgroundColor: Color(0xFFD1A681),
        automaticallyImplyLeading: false, //gets rid of auto back arrow
        title: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                TextButton(
                  onPressed: () => controller.onPressedMail(context), 
                  child: Text(
                    'Mail',
                    style: tabStyle(context, '/mailScreen'),
                  )),
                TextButton(
                  onPressed: () => controller.onPressedMyCoop(context), 
                  child: Text(
                    'My Coop',
                    style: tabStyle(context, '/myCoopScreen'),
                  )),
              ],
            );
          },
        ),
        actions: [
          IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => controller.onPressedProfile(context),
        ),
        ],
      ),
      body: child,
    );
  }
}