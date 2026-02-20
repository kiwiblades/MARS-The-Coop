import 'package:flutter/material.dart';

class MyCoopScreen extends StatefulWidget {
  static const String routeName = '/myCoopScreen';
  const MyCoopScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyCoopScreenState();
  }
}

class MyCoopScreenState extends State<MyCoopScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("My Coop screen"),
    );

  }
}
