import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Title Test'),
        title: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                TextButton(onPressed: () {
                  Navigator.pushNamed(context, '/mailScreen');
                }, child: const Text('Mail')),
                TextButton(onPressed: () {
                  Navigator.pushNamed(context, '/myCoopScreen');
                }, child: const Text('My Coop')),
              ],
            );
          },
        ),
        actions: [
          IconButton(
          icon: const Icon(Icons.person),
          // tooltip: 'Increase volume by 10',
          onPressed: () {},
        ),
        ],
      ),
      body: child,
    );
  }
}