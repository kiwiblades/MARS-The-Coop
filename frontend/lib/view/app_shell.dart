import 'package:flutter/material.dart';
import 'package:frontend/controller/appshell_controller.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final AppShellController controller;
  AppShell({super.key, required this.child}) : controller = AppShellController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1A681),
      appBar: AppBar(
      backgroundColor: Color(0xFFD1A681),
        automaticallyImplyLeading: false, //gets rid of auto back arrow
        title: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                TextButton(onPressed: () => controller.onPressedMail(context), child: const Text('Mail')),
                TextButton(onPressed: () => controller.onPressedMyCoop(context), child: const Text('My Coop')),
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