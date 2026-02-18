import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xFFD1A681),
      appBar: AppBar(
      backgroundColor: Color(0xFFD1A681),
        automaticallyImplyLeading: false, //gets rid of auto back arrow
        title: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                TextButton(onPressed: () { //Mail Button
                  Navigator.pushNamed(context, '/mailScreen'); //routes to mail screen when clicked
                }, child: const Text('Mail')),
                TextButton(onPressed: () { //My Coop Button
                  Navigator.pushNamed(context, '/myCoopScreen'); //navigates to my coop screen when clicked
                }, child: const Text('My Coop')),
              ],
            );
          },
        ),
        actions: [
          IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.pushNamed(context, '/profileScreen');
          },
        ),
        ],
      ),
      body: child,
    );
  }
}